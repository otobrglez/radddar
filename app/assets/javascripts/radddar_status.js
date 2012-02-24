/* By Oto Brglez - <oto.brglez@opalab.com> */

(function($){
	$.fn.extend({ 

		radddar_status: function(options) {

			var defaults = { };
			var options =  $.extend(defaults, options);

			return this.each(function() {
				o = options;
				app = $(this);


				$('.status_field p, .status_field',app).live("click",function(e){
					$("a.update_status_link",app).trigger("click");
				});

				$('.buttonz a[href^="#status_save"]',app).on("click",function(e){
					$("form",app).trigger("submit");
				});

				$('.buttonz a[href^="#status_cancel"]',app).on("click",function(e){
					$.getScript("/status_reload.js");
				});

			});
		}
	});
})(jQuery);