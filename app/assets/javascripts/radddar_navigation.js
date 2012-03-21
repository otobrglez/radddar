/* By Oto Brglez - <oto.brglez@opalab.com> */

var RadddarHistory = new function(){
	this.tab = "radddar"; /* Initial tab */
};

var RadddarNavigation = new function(){
	
};

(function($){
	$.fn.extend({ 
		//pass the options variable to the function
		radddar_navigation: function(options) {

			var defaults = { };
			var options =  $.extend(defaults, options);

			var move_to = function(name,callback){
				var current_tab = $(".tabs-nav a.active").attr("href").substring(1);

				if(name == "back"){
					if(name != RadddarHistory.tab)
						return move_to(RadddarHistory.tab);
					return false;
				};

				$(document).trigger({
					type:"nav:pre_tab_switch",
					current_tab:current_tab,
					tab:name
				});

				$(".tabs-nav a.active").removeClass("active");
				$(".tabs .active").removeClass("active");

				$(".tabs-nav ."+name+" a").addClass("active");
				$(".tabs ."+name).addClass("active");
				
				$(document).trigger({
					type:"nav:post_tab_switch",
					current_tab:name
				});

				//if(typeof(ignore_history) != "undefined" && ignore_history==true)
				RadddarHistory.tab = current_tab;

				if(typeof(callback) != "undefined") callback();
			};

			return this.each(function() {
				var o = options;
				var app = $(this);


				/* Disable all hash events */
				$('a[href^="#"]',app).click(function(e){
					if(e.preventDefault)
						e.preventDefault();
				});

				/* Click on tab on menu on top */
				$(".tabs-nav a").on("click",function(e){	
					var tab = $(this).attr("href").substring(1);
					move_to(tab);
				});

				/* Move to tab event */
				$(document).on("move_to",function(data){
					if(data.tab){
						move_to(data.tab);
					};
				});
				
				/* Event that is triggered when marker is clicked */
				$(document).on("marker_clicked",function(e){
					if(typeof(e.member) == "undefined") return;
					if(typeof(e.member.id) == "undefined") return;
					
					var member_id = e.member.id;
					
					User.load_profile(e.member.id,function(data){
						/* Hide tools if user is not online! */
						if(!User.is_online(member_id))
							$(".tabs .member_profile .profile_tools").hide();

						$(document).trigger({type:"move_to",tab:"member_profile"});
					});
				});



			});
		}
	});

})(jQuery);