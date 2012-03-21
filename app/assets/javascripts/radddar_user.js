/* By Oto Brglez - <oto.brglez@opalab.com> */

var User = new function(){

	/* This is the list of members from pusher */
	this.members = new Array();
	
	/* Get current user object */
	this.get = function(id, callback){
		$.getJSON("/profile/"+id+".json",function(data){
			if(typeof(callback) != "undefined")
				return callback(data);
		});
	};

	this.load_profile = function(id,callback){
		$.getScript("/profile/"+id+".js",callback);
	};
	
	/* Add member to members list */
	this.add_member = function(member,callback){
		if(member.id){
			if(User.members.indexOf(member.id) == -1){
				this.members.push(member.id);
				
				$(document).trigger({
					type:"member_added",
					member: member
				});

				if(typeof(callback) != "undefined") callback(member);
			};
		};
	};

	/* Remove member from members list */
	this.remove_member = function(member,callback){
		if(member.id){
			if(this.members.indexOf(member.id) != -1){
				this.members.splice(this.members.indexOf(member.id),1);				
				
				$(document).trigger({
					type:"member_removed",
					member: member
				});
				
				if(typeof(callback) != "undefined") callback(member);
			};			
		};
	};

	/* User is member */
	this.is_online = function(member){
		if(this.members.length == 0) return false;
		if(typeof(member) == "object"){
			if(this.members.indexOf(member.id) != -1)
				return true;
		}else{
			if(this.members.indexOf(member) != -1)
				return true;
		};
		return false;
	};
	
	/* Returns list of users from live list
	this.live_users_from_list = function(){
		return _.map($("div.live_list .users li.on"),function(u){
			return $(u).data("id");
		})
	};
	 */

	this.live_users_from_list = function(){
		return _.map($("div.live_list .users li.on"),function(u){
			return $(u).data();
		})
	};

	this.users_from_list = function(){
		return _.map($("div.live_list .users li"),function(u){
			return $(u).data();
		});
	};

	this.jq_user_from_list = function(user){
		if(typeof(user) == "object"){
			return $("li.user[data-id='"+(user.id)+"']:first");
		}else{
			return $("li.user[data-id='"+(user)+"']:first");
		};
		return null;
	};

	this.from_list = function(user){
		var us = this.jq_user_from_list(user);
		if(us.length != 0) return us.data();
		return null;
	};

};