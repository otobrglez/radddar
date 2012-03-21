var RadddarAlerts = new function(){

	this.add_alert = function(){
		var p = $(".tabs-nav .chat .alerts_wrap");
		var number = parseInt($("span",p).html(),0);

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