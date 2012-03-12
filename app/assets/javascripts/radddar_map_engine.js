/* By Oto Brglez - <oto.brglez@opalab.com> */

(function($){
	$.fn.extend({ 
		radddar_map_engine: function(options) {

			var defaults = { };
			var options =  $.extend(defaults, options);

			var refresh_location_from_browser = function(){
				if (navigator.geolocation) {
				  navigator.geolocation.getCurrentPosition(function(data){
				  	return RadddarMap.move_to_point_and_save([
				  		data.coords.latitude,
				  		data.coords.longitude]);

				  },function(data){
				  	alert("No GEO information from you :/")
				  });
				} else {
					alert("Your browser does not support GEOlocation magic :(");
				};

			};

			return this.each(function() {
				o = options;
				app = $(this);

				/* This is for layout hack */
				$(document).bind("nav:pre_tab_switch",function(e){
					if(e.tab=="radddar"){$("#map").css("z-index",20); };
					if(e.current_tab=="radddar"){$("#map").css("z-index",5); };
				});

				/* Reload location from browser */
				$('.status_tools a[href^="#refresh_location"]').on("click",function(){
					refresh_location_from_browser();
				});

				/* Init */
				CurrentUser.current_user(function(data){
					var options = {};

					if(typeof(data.loc) != "undefined"){
						options = { center:
							new google.maps.LatLng(data.loc[0], data.loc[1]) };
					} else {
						// ask for location
					};

					RadddarMap.initialize(options);
				
				});
				

			});
		}
	});
})(jQuery);