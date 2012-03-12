/* By Oto Brglez - <oto.brglez@opalab.com> */

(function($){
	$.fn.extend({ 
		//pass the options variable to the function
		radddar_navigation: function(options) {

			var defaults = { };
			var options =  $.extend(defaults, options);

			var move_to = function(name,callback){
				var current_tab = $(".tabs-nav a.active").attr("href").substring(1);

				$(document).trigger({
					type:"nav:pre_tab_switch",
					current_tab:current_tab,
					tab:name
				});

				$(".tabs .active, .tabs-nav a.active").removeClass("active");

				$(".tabs ."+name).addClass("active");
				$(".tabs-nav a."+name).addClass("active");

				// $(this).addClass("active");

				$(document).trigger({
					type:"nav:post_tab_switch",
					current_tab:name
				});

				if(typeof(callback) != "undefined")
					callback();
			};

			return this.each(function() {
				var o = options;
				var app = $(this);


				$('a[href^="#"]',app).click(function(e){
					if(e.preventDefault) e.preventDefault();
				});

				$(".tabs-nav a").on("click",function(e){
					var tab = $(this).attr("href").substring(1);
					move_to(tab);
				});

				$(document).on("move_to",function(data){
					if(data.tab){
						move_to(data.tab);
					};
				});
				
				$(document).on("marker_clicked",function(e){
					// $(document).trigger({type:"move_to",tab:"xxx"});
					console.log("load new profile...");
					console.log(e.member);
				});

			});
		}
	});

})(jQuery);