/* By Oto Brglez - <oto.brglez@opalab.com> */

var RadddarChat = new function(){

	/* Reload feeds */
	this.reload_chat_feed = function(callback){
		$.getScript("/reload_chat_feed.js",callback);
	};

	/* Load chat and exceture remote */
	this.get = function(user,jump,callback){
		var who = (typeof(user)=="object")?user.id:user;
		if(typeof(jump)!="undefined" && jump==true){
			$.getScript("/chat/"+who+".js?jump=1",callback);
		} else{
			$.getScript("/chat/"+who+".js?jump=0",callback);
		};
	};

	/* When someone sends notification */
	this.notification_received = function(data){
		this.reload_chat_feed(function(){
			RadddarAlerts.add_alert();
		});
	};

	/* Open chat if its not open */
	this.is_open = function(user){
		var who = (typeof(user)=="object")?user.id:user;
		return $(".tabs li.live-chat[data-id='"+who+"']").length==0?false:true;
	};

	/* Get active chat */
	this.active_chat = function(){
		var chat = $(".tabs .chats ul li.live-chat.act");
		if(chat.length != 0) return chat.data("id");
		return false;
	};

	this.get_chat = function(user){
		var who = (typeof(user)=="object")?user.id:user;
		return $(".tabs .chats ul li.live-chat[data-id='"+who+"']");
	};

	/* Open chat */
	this.open_chat = function(user,messages_html,message_form,move_to){
		var who = (typeof(user)=="object")?user.id:user;

		if(this.is_open(who)){
			var current_chat = $(".tabs .chats ul li.live-chat[data-id='"+who+"']");
			$(".messages-wrap",current_chat).html(messages_html);
			$("li.live-chat").removeClass("act");
			current_chat.addClass("act");
			$(".message_body",current_chat).focus();
		} else {
			var chats = $(".tabs .chats ul.live-chat-list");
			var chat = $('<li class="live-chat act" data-id="'+who+'">'+
				'<div class="messages-wrap"></div>'+
				'<div class="message-form"></div></li>');
			$(".messages-wrap",chat).append(messages_html);
			$(".message-form",chat).append(message_form);
			$("li.live-chat").removeClass("act");
			chat.appendTo(chats);
			$(".message_body",chat).focus();
		};

		if(typeof(move_to) != "undefined" && move_to==true){
			//TODO: Remove notifications!
			$(document).trigger({type:"move_to",tab:"chats"});
		} else {
			
		};
	};

	/* Triggered when message is sent */
	this.message_sent = function(user,message_html,message_form){
		var who = (typeof(user)=="object")?user.id:user;

		if(this.is_open(who)){
			var chat = $(".tabs .chats ul li.live-chat[data-id='"+who+"']");
			var messages = $("ul",chat);
			$(message_html).appendTo(messages);
			$(".message-form",chat).html(message_form);
			$(".message_body",chat).val("");
			$(".message_body",chat).focus();

			$(".error",chat).delay(1000).fadeOut("slow",function(){
				$(this).remove();
			});
		};
	};

	/* Message revieved */
	this.message_received = function(data){
		var user = data;

		/* If chat is opened append */
		if(this.is_open(user.sender)){

			/* Build new message */
			var message = $('<li class="message their">'+
				'<span class="created_at"></span> - <span class="body"></span></li>');
			$(".created_at",message).html(user.human_time);
			$(".body",message).html(user.body);

			var chat = this.get_chat(user.sender);
			var messages = $(".messages ul",chat);
			message.appendTo(messages);

		} else{
			this.reload_chat_feed(function(){
				RadddarChat.get(user.sender,false,function(){ });
			});
		};

		// Add alert...
		//if(RadddarNavigation.current_content_tab() != "chat"){
			if(RadddarNavigation.current_content_tab() == "chats"){
				var active_chat = this.active_chat();
				var sender_chat = user.sender;
				if(active_chat != sender_chat)
					RadddarAlerts.add_alert(sender_chat);
			} else {
				RadddarAlerts.add_alert(user.sender);
			};
		//};
	};
};

(function($){
	$.fn.extend({ 
		radddar_chat: function(options){
			var defaults = { };
			var options =  $.extend(defaults, options);

			return this.each(function() {
				/*
				o = options;
				app = $(this);
				*/

				
				$(".message_body").live("keydown",function(e){
					var c = e.which ? e.which : e.keyCode;
					if(c==13){
						$(this).parents("form").trigger("submit");
						return false;
					};
				});

				/* Before moving to chat tab */
				$(document).bind("nav:pre_tab_switch",function(e){
					if(e.tab=="chat"){
						RadddarChat.reload_chat_feed(function(){
							RadddarAlerts.remove_alerts();
						});
					};
				});

				/* Offline users can not receive messages */
				$(document).bind("nav:post_tab_switch",function(e){
					if(e.current_tab=="chats"){
						var user = RadddarChat.active_chat();
						if(user==false) return;
						var chat = RadddarChat.get_chat(user).removeClass("offline");
						if(!User.is_online(user)) chat.addClass("offline");
					};
				});

			});

		}
	})
})(jQuery);
