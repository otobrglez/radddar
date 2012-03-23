// By Oto Brglez - <oto.brglez@opalab.com>
//= require jquery
//= require jquery_ujs

var tick_time = 4000;
var animate_time = 2000;
var timer = null;

var move_slide = function(){

	var next = $("#screens li.active").next();
	if(next.length == 0)
		next = $("#screens li:first");

	$("#screens li.active").removeClass("active");
	next.addClass("active");

	$("#screens ul").animate({
		marginLeft: "-"+(212*next.index())
	},animate_time);

	timer = setTimeout("move_slide()",tick_time);
};


$(function(){
	timer = setTimeout("move_slide()",tick_time);
	$("a.video-toggle").click(function(e){

		if(e.preventDefault) e.preventDefault();
		var myPlayer = document.getElementById('ytplayer');

		if($(".video").hasClass("off")){
			$(".video").removeClass("off");
			$(".video").fadeIn("slow");
			if(myPlayer.playVideo) myPlayer.playVideo();
		} else {
			$(".video").addClass("off");
			$(".video").fadeOut("slow");
			if(myPlayer.stopVideo) myPlayer.stopVideo();
		};
	});

});