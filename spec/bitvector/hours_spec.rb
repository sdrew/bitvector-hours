RSpec.describe BitVector::Hours do
  it "has a version number" do
    expect(BitVector::Hours::VERSION).not_to be nil
  end

  context "default" do
    it "sets resolution, size and vector" do
      expect(subject.resolution).to eq(5)
      expect(subject.size).to eq(288)
      expect(subject.vector).to be_a(BitVector::BitVector)
    end

    it "has empty hours and ranges" do
      expect(subject.hours).to be_empty
      expect(subject.ranges).to be_empty
    end
  end

  context "initialized" do
    let(:vector) { "40000000-00000000-00000000-00000000-00000000-00000000-00000000-00000000-00000002" }
    subject { BitVector::Hours.new vector }

    it "raises BitVector::Hours::Error for mismatched resolution" do
      expect { BitVector::Hours.new vector, resolution: 10 }.to raise_exception BitVector::Hours::Error
    end

    it "has correct bits set" do
      expect(subject.vector.to_s).to start_with('010')
      expect(subject.vector.to_s).to end_with('010')
      expect(subject.vector.to_s.count('0')).to eq(286)
    end

    it "has hours and ranges" do
      expect(subject.hours).to eq([["00:05", "00:10"], ["23:50", "23:55"]])
      expect(subject.ranges).to eq([1...2, 286...287])
    end

    it "can be encoded" do
      expect(subject.to_s).to eq(vector)
    end

    context "#active?" do
      before { travel_to Time.local(2010, 6, 15) }
      after  { travel_back }

      it "checks current time" do
        expect(subject.current_bit).to eq(0)
        expect(subject.active?).to be false

        travel 5.minutes
        expect(subject.current_bit).to eq(1)
        expect(subject.active?).to be true

        travel 5.minutes
        expect(subject.current_bit).to eq(2)
        expect(subject.active?).to be false
      end

      it "checks with bit" do
        expect(subject.active? bit:   0).to be false
        expect(subject.active? bit: 144).to be false
        expect(subject.active? bit: 287).to be false

        expect(subject.active? bit:   1).to be true
        expect(subject.active? bit: 286).to be true
      end

      it "checks with hour string" do
        expect(subject.active? hour: "00:04").to be false
        expect(subject.active? hour: "00:05").to be true
        expect(subject.active? hour: "00:09").to be true
        expect(subject.active? hour: "00:10").to be false
      end
    end

    context "can be expanded" do
      let(:expanded_range) { [1...2, 140...148, 286...287] }
      let(:expanded_vector) { "40000000-00000000-00000000-00000000-000ff000-00000000-00000000-00000000-00000002" }

      it "with ranges" do
        subject.expand 140...148

        expect(subject.ranges).to eq(expanded_range)
        expect(subject.to_s).to eq(expanded_vector)
      end

      it "with bit array" do
        subject.expand [140, 148]

        expect(subject.ranges).to eq(expanded_range)
        expect(subject.to_s).to eq(expanded_vector)
      end

      it "with hours array" do
        subject.expand ["11:40", "12:20"]

        expect(subject.ranges).to eq(expanded_range)
        expect(subject.to_s).to eq(expanded_vector)
      end
    end

    context "can be cleared" do
      let(:cleared_range) { [1...2, 140...142, 146...148, 286...287] }
      let(:cleared_vector) { "40000000-00000000-00000000-00000000-000c3000-00000000-00000000-00000000-00000002" }

      it "with ranges" do
        subject.expand 140...148
        subject.clear 142...146

        expect(subject.ranges).to eq(cleared_range)
        expect(subject.to_s).to eq(cleared_vector)
      end

      it "with bit array" do
        subject.expand 140...148
        subject.clear [142, 146]

        expect(subject.ranges).to eq(cleared_range)
        expect(subject.to_s).to eq(cleared_vector)
      end

      it "with hours array" do
        subject.expand ["11:40", "12:20"]
        subject.clear ["11:50", "12:10"]

        expect(subject.ranges).to eq(cleared_range)
        expect(subject.to_s).to eq(cleared_vector)
      end
    end

    context "timezones" do
      around(:each) do |example|
        Time.use_zone('UTC') do
          travel_to Time.utc(2010, 6, 15) do
            example.run
          end
        end
      end

      it "can be set" do
        subject.expand ["4:55", "5:05"]

        expect(subject.current_time.hour).to eq(0) # UTC

        Time.use_zone('America/New_York') do
          expect(subject.current_time.hour).to eq(20) # A/N_Y
          expect(subject.current_hour).to eq("20:00")
          expect(subject.current_bit).to eq(240)
          expect(subject.active?).to be false

          subject.timezone = 'America/Los_Angeles'
          expect(subject.current_time.hour).to eq(17) # A/L_A
          expect(subject.current_hour).to eq("17:00")
          expect(subject.current_bit).to eq(204)
          expect(subject.active?).to be false

          travel 9.hours

          expect(subject.current_time.hour).to eq(2) # A/L_A
          expect(subject.current_hour).to eq("02:00")
          expect(subject.current_bit).to eq(24)
          expect(subject.active?).to be false

          subject.timezone = nil
          expect(subject.current_time.hour).to eq(5) # A/N_Y
          expect(subject.current_hour).to eq("05:00")
          expect(subject.current_bit).to eq(60)
          expect(subject.active?).to be true
        end
      end
    end

    context "private methods" do
      it "#array_to_range raises errors for invalid array ranges" do
        expect { subject.send(:array_to_range, []) }.to raise_error(::BitVector::Hours::Error)
        expect { subject.send(:array_to_range, [1]) }.to raise_error(::BitVector::Hours::Error)
        expect { subject.send(:array_to_range, ["20:00"]) }.to raise_error(::BitVector::Hours::Error)

        expect { subject.send(:array_to_range, [1, "20:00"]) }.to raise_error(::BitVector::Hours::Error)

        expect { subject.send(:array_to_range, ["", "20:00"]) }.to raise_error(::BitVector::Hours::Error)
        expect { subject.send(:array_to_range, ["2000", "20:00"]) }.to raise_error(::BitVector::Hours::Error)
        expect { subject.send(:array_to_range, ["20:0", "20:00"]) }.to raise_error(::BitVector::Hours::Error)
        expect { subject.send(:array_to_range, ["0:0", "20:00"]) }.to raise_error(::BitVector::Hours::Error)

        expect { subject.send(:array_to_range, [nil, nil]) }.to raise_error(::BitVector::Hours::Error)
        expect { subject.send(:array_to_range, [{}, {}]) }.to raise_error(::BitVector::Hours::Error)
      end

      it "#array_to_range returns expected ranges" do
        expect(subject.send(:array_to_range, [1, 10])).to eq(1...10)
        expect(subject.send(:array_to_range, [1.0, 10.0])).to eq(1...10)

        expect(subject.send(:array_to_range, ["2:00", "4:00"])).to eq(24...48)
        expect(subject.send(:array_to_range, ["20:00", "21:00"])).to eq(240...252)
      end

      it "#bit_to_time converts to time" do
        expect(subject.send(:bit_to_time, 0).strftime('%H:%M')).to eq('00:00')
        expect(subject.send(:bit_to_time, 1).strftime('%H:%M')).to eq('00:05')
        expect(subject.send(:bit_to_time, 2).strftime('%H:%M')).to eq('00:10')

        expect(subject.send(:bit_to_time, 287).strftime('%H:%M')).to eq('23:55')
      end
    end

  end
end
