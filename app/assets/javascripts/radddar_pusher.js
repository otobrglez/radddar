/* By Oto Brglez - <oto.brglez@opalab.com> */

(function($){

	var pusher, private_channel, presence_channel = null;

	var options={
		app_id:null
	};

	var methods={
		init:function(options){
 
 			var $this = $(this);
 			this.options = options

 			if(typeof(this.options.app_id)!="undefined"){ // Connect to Pusher
 				Pusher.channel_auth_endpoint = '/auth';
				
				Pusher.log = function(message) {
      				return;
      				if (window.console && window.console.log)
      					window.console.log(message);
    			};

 				this.pusher = new Pusher(this.options.key);

 				// Private channel for user
 				this.private_channel = this.pusher.subscribe(
 					this.options.user.private_channel);

 				// Presence channel
 				this.presence_channel = this.pusher.subscribe("presence-radddar");
 				
 				//
 				this.presence_channel.bind("pusher:subscription_succeeded",function(members){
 					User.members = _.map(members._members_map,function(i,j){ return j; });
 					Status.update_swap();
 				});

 				// User joins
 				this.presence_channel.bind("pusher:member_added",function(member){
 					User.add_member(member,Status.update_swap);
 				});

 				// User leaves
 				this.presence_channel.bind("pusher:member_removed",function(member){
 					User.remove_member(member,Status.update_swap);
 				});

 				// Update swap information
 				this.private_channel.bind("status-update_swap",function(data){
 					Status.update_swap();
 				});
 			};

 			/*
 			return this.each(function(){
 				methods.auth();
 			});
			*/

 			return $this;
		}
	};


	$.fn.radddar_pusher = function(method){
		if ( methods[method] ) {
	      return methods[method].apply(this,
	      	Array.prototype.slice.call(arguments,1));
	    } else if ( typeof method === 'object' || ! method ) {
	      return methods.init.apply( this, arguments );
	    } else {
	      $.error( 'Method ' +  method + ' does not exist on jQuery.tooltip' );
	    };

	    return this;	
	};

})(jQuery);