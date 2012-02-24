/* By Oto Brglez - <oto.brglez@opalab.com> */

(function($){
	$.fn.extend({ 
		//pass the options variable to the function
		radddar_navigation: function(options) {

			var defaults = { };
			var options =  $.extend(defaults, options);

			return this.each(function() {
				var o = options;
				var app = $(this);

				$('a[href^="#"]',app).click(function(e){
					if(e.preventDefault) e.preventDefault();
				});

				$(".tabs-nav a").on("click",function(e){
					var current_tab = $(".tabs-nav a.active").attr("href").substring(1);
					var tab = $(this).attr("href").substring(1);

					// Trigger "nav:pre_tab_switch"
					$(document).trigger({type:"nav:pre_tab_switch",current_tab:current_tab,tab:tab});

					// Switching tab
					$(".tabs .active, .tabs-nav a.active").removeClass("active");

					var tab_e = $(".tabs ."+tab,app);
					tab_e.addClass("active");

					$(this).addClass("active");

					// Trigger "nav:post_tab_switch"
					$(document).trigger({type:"nav:post_tab_switch",current_tab:tab});

				});
				

			});
		}
	});

})(jQuery);