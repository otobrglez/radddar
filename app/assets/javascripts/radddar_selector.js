/* By Oto Brglez - <oto.brglez@opalab.com> */

(function($){
	$.fn.extend({ 

		radddar_selector: function(options) {

			var defaults = { };
			var options =  $.extend(defaults, options);
			var o = null;
			var app = null;

			var fix_navigation = function(app_n){
				
				var current_value = $(".current_value",app_n).val()
					.replace(/^\s*/, "").replace(/\s*$/, "");
				
				var next_value = null;
				var prev_value = null;

				var n = $(".v_"+current_value,app_n);

				next_value = n.next();
				prev_value = n.prev();

				if(next_value.length ==0){
					$(".right a",app_n).addClass("none");
				}else{
					$(".right a",app_n).removeClass("none");
				};

				if(prev_value.length ==0){
					$(".left a",app_n).addClass("none");
				}else{
					$(".left a",app_n).removeClass("none");
				};
			};

			return this.each(function() {
				o = options;
				app = $(this);

				if(app.parent().hasClass("gender")){
					$(document).bind("selector:switch",function(e){
						if($(e.selector).parent().parent().hasClass("gender")){
							var value = e.value.trim()==""?"none":e.value;
							$(".profile .profile_header")
								.removeClass("male female none")
								.addClass(value);
						};				
					});
				};

				fix_navigation(app);

				$(".left a, .right a",app).on("click",function(e){
					var app_n = $($(this).parent().parent());
					var current_value = $(".current_value",app_n).val()
						.replace(/^\s*/, "").replace(/\s*$/, "");
					var n = $(".v_"+current_value,app_n);
					var next_value = n.next();
					var prev_value = n.prev();

					if($(this).parent().hasClass("left")){ // left
						if(prev_value.length == 0) return;
						$(".current",app_n).html($(prev_value).html());
						
						$(".current_value",app_n).val(
							$(prev_value).attr("class").substring(2)
						);

						$(document).trigger({type:"selector:switch",
							selector:app_n,
							value:$(".current_value",app_n).val(),
							direction:'left'
						});

					}else{ // right
						if(next_value.length == 0) return;
						$(".current",app_n).html($(next_value).html());
						
						$(".current_value",app_n).val(
							$(next_value).attr("class").substring(2)
						);
	
						$(document).trigger({type:"selector:switch",
							selector:app_n,
							value:$(".current_value",app_n).val(),
							direction:'right'
						});
					};

					var form = $("form",app_n.parent()).trigger("submit");
					fix_navigation(app_n);
				});
			});
		}
	});
})(jQuery);