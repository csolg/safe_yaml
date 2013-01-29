require File.join(File.dirname(__FILE__), "spec_helper")

module SharedSpecs
  def self.included(base)
    base.instance_eval do
      context "by default" do
        it "translates maps to hashes" do
          parse <<-YAML
            potayto: potahto
            tomayto: tomahto
          YAML

          result.should == {
            "potayto" => "potahto",
            "tomayto" => "tomahto"
          }
        end

        it "translates sequences to arrays" do
          parse <<-YAML
            - foo
            - bar
            - baz
          YAML

          result.should == ["foo", "bar", "baz"]
        end

        it "translates most values to strings" do
          parse "string: value"
          result.should == { "string" => "value" }
        end

        it "does not deserialize symbols" do
          parse ":symbol: value"
          result.should == { ":symbol" => "value" }
        end

        it "translates valid integral numbers to integers" do
          parse "integer: 1"
          result.should == { "integer" => 1 }
        end

        it "translates valid decimal numbers to floats" do
          parse "float: 3.14"
          result.should == { "float" => 3.14 }
        end

        it "translates valid dates" do
          parse "date: 2013-01-24"
          result.should == { "date" => Date.parse("2013-01-24") }
        end

        it "translates valid time values" do
          parse "time: 2013-01-29 05:58:00 -0800"
          result.should == { "time" => Time.new(2013, 1, 29, 5, 58, 0, "-08:00") }
        end

        it "translates valid true/false values to booleans" do
          parse <<-YAML
            - yes
            - true
            - no
            - false
          YAML

          result.should == [true, true, false, false]
        end

        it "translates valid nulls to nil" do
          parse <<-YAML
            - 
            - ~
            - null
          YAML

          result.should == [nil] * 3
        end

        it "deals just fine with nested maps" do
          parse <<-YAML
            foo:
              bar:
                marco: polo
          YAML

          result.should == { "foo" => { "bar" => { "marco" => "polo" } } }
        end

        it "deals just fine with nested sequences" do
          parse <<-YAML
            - foo
            -
              - bar1
              - bar2
              -
                - baz1
                - baz2
          YAML

          result.should == ["foo", ["bar1", "bar2", ["baz1", "baz2"]]]
        end

        it "applies the same transformations to keys as to values" do
          parse <<-YAML
            foo: string
            :bar: symbol
            1: integer
            3.14: float
            2013-01-24: date
            2013-01-29 05:58:00 -0800: time
          YAML

          result.should == {
            "foo"  => "string",
            ":bar" => "symbol",
            1      => "integer",
            3.14   => "float",
            Date.parse("2013-01-24") => "date",
            Time.new(2013, 1, 29, 5, 58, 0, "-08:00") => "time"
          }
        end

        it "applies the same transformations to elements in sequences as to all values" do
          parse <<-YAML
            - foo
            - :bar
            - 1
            - 3.14
            - 2013-01-24
            - 2013-01-29 05:58:00 -0800
          YAML

          result.should == ["foo", ":bar", 1, 3.14, Date.parse("2013-01-24"), Time.new(2013, 1, 29, 5, 58, 0, "-08:00")]
        end
      end

      context "with symbol parsing enabled" do
        before :each do
          YAML.enable_symbol_parsing = true
        end

        it "translates values starting with ':' to symbols" do
          parse "symbol: :value"
          result.should == { "symbol" => :value }
        end

        it "applies the same transformations to keys as to values" do
          parse <<-YAML
            foo: string
            :bar: symbol
            1: integer
            3.14: float
            2013-01-24: date
            2013-01-29 05:58:00 -0800: time
          YAML

          result.should == {
            "foo" => "string",
            :bar  => "symbol",
            1     => "integer",
            3.14  => "float",
            Date.parse("2013-01-24") => "date",
            Time.new(2013, 1, 29, 5, 58, 0, "-08:00") => "time"
          }
        end

        it "applies the same transformations to elements in sequences as to all values" do
          parse <<-YAML
            - foo
            - :bar
            - 1
            - 3.14
            - 2013-01-24
            - 2013-01-29 05:58:00 -0800
          YAML

          result.should == ["foo", :bar, 1, 3.14, Date.parse("2013-01-24"), Time.new(2013, 1, 29, 5, 58, 0, "-08:00")]
        end
      end
    end
  end
end
