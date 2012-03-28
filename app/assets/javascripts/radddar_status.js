/* By Oto Brglez - <oto.brglez@opalab.com> */

var Status = new function(){

	// Do the swap call
	this.swap = function(callback){
		return $.getJSON("/swap.json",function(data){
			if(typeof(callback) != "undefined")
				return callback(data);
		});
	};

	// Update swap information
	this.update_swap = function(callback){
		Status.swap(function(data,callback){
			
			if(typeof(data.stat_html) != "undefined")
				$("div.stat").html($(data.stat_html));

			if(typeof(data.live_list_html) != "undefined")
				$("div.live_list").html($(data.live_list_html));

			/* Mark users that are actualy online with white background (class=on) */
			var push_list = User.members;
			/* div.live_list  */
			
			// $(".users li.on").removeClass("on");

			var live_list = User.users_from_list();
			RadddarMap.remove_all_markers();
			if(live_list.length != 0){
				for(var i in live_list){
					if(User.is_online(live_list[i])){
						$("li.user[data-id='"+(live_list[i].id)+"']").addClass("on");
						RadddarMap.add_user_marker(live_list[i]);
					} else {
						$("li.user[data-id='"+(live_list[i].id)+"']").removeClass("on");
						RadddarMap.add_user_marker(live_list[i],true);
					};
				};
			};

			if(typeof(callback) != "undefined") return callback(data);
		});
	};

};

(function($){
	$.fn.extend({ 

		radddar_status: function(options) {

			var defaults = { };
			var options =  $.extend(defaults, options);

			return this.each(function() {
				o = options;
				app = $(this);

				$('.status_field p, .status_field').live("click",function(e){
					$("a.update_status_link").trigger("click");
				});

				$('.buttonz a[href^="#status_save"]').live("click",function(e){
					$(".set_status_form form").trigger("submit");
				});

				$('.buttonz a[href^="#status_cancel"]',app).live("click",function(e){
					$.getScript("/status_reload.js");
				});

			});
		}
	});
})(jQuery);