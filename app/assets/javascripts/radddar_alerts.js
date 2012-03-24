var RadddarAlerts = new function(){

	/* For radddar tab! */
	this.add_radddar_alert = function(){
		var p = $(".tabs-nav .radddar .alerts_wrap");
		var number = parseInt($("span",p).html(),0);

		if(number+1 >= 1){
			$(p).fadeOut("slow",function(){
				$("span",p).html(number+1);
			}).delay(400).fadeIn("slow");
			return number+1;
		};

		return number;
	};

	/* For Radddar alerts */
	this.remove_radddar_alerts = function(){
		var p = $(".tabs-nav .radddar .alerts_wrap");
		p.fadeOut("slow",function(){
			$("span",p).html("0");
		});
	};

	// Chat alert!
	this.add_alert = function(sender){
		var p = $(".tabs-nav .chat .alerts_wrap");
		var number = parseInt($("span",p).html(),0);

		// if sender... add to list also!
		if(typeof(sender) != "undefined"){
			var chat = $('.chat .users .chat[data-id="'+sender+'"]');

			console.log(chat);
			var number_n = parseInt($("span",chat).html(),0);
			$("span",chat).html(number_n+1);
			$(".alerts_wrap",chat).fadeIn("slow");
		};

		if(number+1 >= 1){
			$(p).fadeOut("slow",function(){
				$("span",p).html(number+1);
			}).delay(400).fadeIn("slow");
		
			return number+1;
		};


		

		return number;
	};

	this.remove_alert = function(){
		var p = $(".tabs-nav .chat .alerts_wrap");
		var number = parseInt($("span",p).html(),0);

		if(number <= 0) return number;

		$(p).fadeOut("slow",function(){
			$("span",p).html(number-1);
		}).delay(400).fadeIn("slow");

		if(number-1 <= 0){
			$(p).fadeOut("fast");
		};

		return number;
	}

	this.remove_alerts = function(){
		var p = $(".tabs-nav .chat .alerts_wrap");
		p.fadeOut("slow",function(){
			$("span",p).html("0");
		});
	};

};