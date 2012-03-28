require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the AppHelper. For example:
#
# describe AppHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ApplicationHelper do

	describe "stat helper" do
		it "does the coloring" do
			helper.should respond_to :humanize_stat
		end

		it "works for nobody" do
			test_stat = {
				female: 0,
				male: 0,
				none: 0
			}

			pstr = User.stat_to_human(test_stat)
			pstr = helper.humanize_stat(pstr)
			pstr.should == "Nobody is around you."

			pstr = User.stat_to_human(test_stat.merge({male:1}))
			pstr = helper.humanize_stat(pstr)
			pstr.should =~ /class/
		end

		it "works for big numbers also" do
			test_stat = {
				female: 10,
				male: 10,
				none: 0
			}

			pstr = User.stat_to_human(test_stat)
			pstr = helper.humanize_stat(pstr)
			pstr.should =~ />\d+/

		end
	end

end
