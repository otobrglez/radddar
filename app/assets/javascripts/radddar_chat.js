/* By Oto Brglez - <oto.brglez@opalab.com> */

var RadddarChat = new function(){

	this.reload_chat_feed = function(callback){
		$.getScript("/reload_chat_feed.js",callback);
	};

	this.notification_received = function(data){
		this.reload_chat_feed(function(){
			RadddarAlerts.add_alert();
		});
	};
};

(function($){
	$.fn.extend({ 
		radddar_chat: function(options){
			var defaults = { };
			var options =  $.extend(defaults, options);

			return this.each(function() {
				o = options;
				app = $(this);

				/* When you click on chat
					1) remove alerts
					2) reload feeds
				*/

				$(document).bind("nav:pre_tab_switch",function(e){
					if(e.tab=="chat"){
						RadddarChat.reload_chat_feed(function(){
							RadddarAlerts.remove_alerts();
						});
					};
				});

			});

		}
	})
})(jQuery);
