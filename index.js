var ref$,w,h,patw,path,of1x,of1y,dpw,dph,x$;ref$=[1170,658],w=ref$[0],h=ref$[1],ref$=[193,278],patw=ref$[0],path=ref$[1],ref$=[298,273],of1x=ref$[0],of1y=ref$[1],ref$=[59,20],dpw=ref$[0],dph=ref$[1],x$=angular.module("ERGame",[]),x$.controller("ERGame",["$scope","$interval","$timeout"].concat(function(t,e,n){var r,i,a,o,s,u,c;for(r=[],i=0;12>i;++i)a=i,r.push([a%4,parseInt(a/4)]);return t.list=r,t.pixel={scene:{w:1170,h:658},sprite:{size:[{w:0,h:0},{w:101,h:142},{w:108,h:229},{w:108,h:229},{w:291,h:245},{w:316,h:269},{w:105,h:196},{w:146,h:239},{w:98,h:60},{w:306,h:298},{w:191,h:240},{w:104,h:136},{w:238,h:184}],points:[{x:591,y:-19,type:6}].concat([{x:317,y:2,type:5}],[{x:687,y:-36,type:7}],[{x:503,y:65,type:8}],[{x:507,y:54,type:9,variant:1}],[{x:249,y:184,type:11}],function(){var t,e,n=[];for(t=0;3>t;++t)for(o=t,e=0;4>e;++e)s=e,n.push({x:293+59*s+-127*o,y:222+20*s+47*o,type:1,variant:0,active:1});return n}(),[{x:857,y:100,type:4,variant:0,active:1}],[{x:870,y:272,type:12}],function(){var t,e=[];for(t=0;5>t;++t)a=t,e.push({x:749+66*a,y:227+24*a,type:2,variant:0,active:1});return e}(),[{x:623,y:279,type:3,variant:0,active:1},{x:520,y:341,type:10},{x:730,y:387,type:4,variant:0,active:1},{x:335,y:387,type:4,variant:0,active:1},{x:493,y:418,type:3,variant:0,active:1},{x:678,y:418,type:2,variant:0,active:1}])}},t.percent={sprite:{size:function(){var e,n,r,i=[];for(e=0,r=(n=t.pixel.sprite.size).length;r>e;++e)u=n[e],i.push({w:100*u.w/t.pixel.scene.w,h:100*u.h/t.pixel.scene.h});return i}(),points:function(){var e,n,r,i=[];for(e=0,r=(n=t.pixel.sprite.points).length;r>e;++e)u=n[e],i.push({x:100*u.x/t.pixel.scene.w,y:100*u.y/t.pixel.scene.h,type:u.type,variant:u.variant,active:u.active});return i}()}},t.rebuild=function(e){var n,r,i,a=[];for(n=0,i=(r=t.percent.sprite.points).length;i>n;++n)e=r[n],a.push(e.cls=["it-"+e.type+"-"+(e.variant||0)+"-"+(e.active||0)]);return a},t.game={state:0,setState:function(t){return this.state=t},start:function(){var t=this;return this.setState(5),n(function(){return t.countdown.start()},300)},reset:function(){return t.patient.reset(),t.doctor.reset(),t.supply.reset(),t.mouse.reset(),t.audio.reset(),t.rebuild(),t.madmax=0,t.dialog.toggle(null,!1),this.state=0},countdown:{handler:null,value:0,count:function(){var e=this;return this.value=this.value-1,this.value>0&&t.audio["count"+(1===this.value?2:1)](),this.value?n(function(){return e.count()},650):(t.game.setState(2),t.audio.bk())},start:function(){return this.value=5,this.count()}}},t.doctor={sprite:t.percent.sprite.points.filter(function(t){return 9===t.type})[0],handler:null,energy:1,faint:!1,chance:5,hurting:0,draining:0,drain:function(){var e;return e=this,e.energy-=.2,e.energy>=0||(e.energy=0),e.draining=1,0===t.doctor.energy?t.doctor.faint=!0:void 0},fail:function(){var e;return e=this,e.setMood(7),e.chance-=1,e.chance>=0||(e.chance=0),e.hurting=1,this.chance<=0&&t.game.setState(4),t.audio.die()},reset:function(){return this.energy=1,this.faint=!1,this.chance=5,this.hurting=0,this.draining=0,this.handler&&n.cancel(this.handler),this.setMood(1)},score:{digit:[0,0,0,0],value:0},resetLater:function(){var e=this;return this.handler&&n.cancel(this.handler),this.handler=n(function(){return e.setMood(1),e.handler=null,t.rebuild()},1e3)},setMood:function(t){return this.sprite.variant=t,t>1?this.resetLater():void 0}},t.$watch("doctor.score.value",function(){var e,n,r,i=[];for(e=t.doctor.score,n=0;4>n;++n)r=n,i.push(e.digit[3-r]=parseInt(e.value/Math.pow(10,r))%Math.pow(10,r+1));return i}),t.supply={sprite:t.percent.sprite.points.filter(function(t){var e;return 5===(e=t.type)||6===e||7===e||8===e}),reset:function(){var t,e,n,r,i=[];for(t=0,n=(e=this.sprite).length;n>t;++t)r=e[t],i.push((r.active=0,r.countdown=-1,r));return i},active:function(t,e){var n,r,i;return null==e&&(e=!0),n=null==t?parseInt(Math.random()*this.sprite.length):t,e?(this.sprite[n].active=1,this.sprite[n].countdown=1):(this.sprite[n].active=0,i=(r=this.sprite[n]).countdown,delete r.countdown,i)}},t.patient={reset:function(){var e,n,r,i,a=[];for(e=t.percent.sprite.points.filter(function(t){return t.type>=1&&t.type<=4}),n=0,r=e.length;r>n;++n)i=e[n],a.push((i.variant=0,i.mad=0,i.life=1,i));return a},add:function(e,n,r){var i,a,o,s,u,c;return i=t.percent.sprite.points.filter(function(t){return t.type===e&&0===t.variant}),0!==i.length?(a=parseInt(3*Math.random()+1),1===e?(o=Math.random(),a=o<t.config.cur.patprob[0]?1:o<t.config.cur.patprob[1]?2:3,t.audio.born()):a=parseInt(2*Math.random()+1),e>1&&(2>=a||(a=2)),null!=n&&(a=n),s=null!=r?r:parseInt(Math.random()*i.length),u=i[s],u.variant=a,1===u.type&&(u.life=1),(2===(c=u.type)||3===c||4===c)&&(u.mad=0),t.rebuild()):void 0}},t.config={cur:{pat:.05,sup:.01,patprob:[.6,.95],mad:.002},setting:[{pat:.02,sup:.01,patprob:[.7,.95],mad:.002},{pat:.07,sup:.04,patprob:[.5,.8],mad:.004},{pat:.15,sup:.11,patprob:[.3,.3],mad:.006}]},t.mouse={x:0,y:0,target:null,reset:function(){return this.target=null},lock:function(){return this.isLocked=!0},unlock:function(){return this.isLocked=!1},down:function(e,n){var r,i,a,o,s,u,d,l,h,p,f;if(!c()&&!(this.isLocked||t.madmax||t.doctor.faint)&&(r=$("#wrapper").offset(),i=[e.clientX-r.left,e.clientY-r.top],this.x=i[0],this.y=i[1],i=i,a=i[0],o=i[1],s=1024*a/$("#wrapper").width(),u=576*o/$("#wrapper").height(),n=t.hitmask.resolve(s,u))){if(1===n.type){if(0===n.variant)return;for(d=t.percent.sprite.points.filter(function(t){return 1===t.type}),l=0,h=0,p=d.length;p>h;++h)f=d[h],f.variant>l&&(l=f.variant);if(3===l&&n.variant<l)return void(this.target=null)}if(this.target=n,n&&1===n.type)return $("#wheel").css({display:"block",top:o+"px",left:a+"px"}),t.audio.blop(),t.rebuild()}},up:function(e){var n=this;if(!c()&&!(this.isLocked||t.madmax||t.doctor.faint))return setTimeout(function(){var r,i,a,o,s,u,c;return $("#wheel").css({display:"none"}),r=$("#wrapper").offset(),i=[e.clientX-n.x-r.left,e.clientY-n.y-r.top],a=i[0],o=i[1],s=360*Math.acos(a/Math.sqrt(Math.pow(a,2)+Math.pow(o,2)))/(2*Math.PI),o>0&&(s=360-s),(s>=320||10>=s)&&(u=3),s>10&&61>=s&&(u=2),s>61&&112>s&&(u=1),n.target&&(1===n.target.type?(n.target.variant===u?1===n.target.variant?(c=Math.random()<.5?2:4+parseInt(3*Math.random()),null!=n.forceMood&&(c=n.forceMood),t.doctor.setMood(c),t.audio.dindon(),2===c&&(t.doctor.score.value+=1)):(null==n.forceStay&&Math.random()>.5?(t.doctor.setMood(3),t.patient.add(parseInt(3*Math.random()+2))):n.forceStay?(t.doctor.setMood(3),t.patient.add(4,2,0)):t.doctor.setMood(2),t.audio.dindon(),t.doctor.score.value+=1):t.doctor.fail(),n.target.variant=0,t.rebuild()):n.target.type>=2&&n.target.type<=4?(n.target.mad>.8&&(n.target.mad=.8),(i=n.target).mad<=.8||(i.mad=.8),n.target.mad-=.2,(i=n.target).mad>=0||(i.mad=0),t.audio.click2()):n.target.type>=5&&n.target.type<=8&&n.target.active&&(t.doctor.energy+=.1,(i=t.doctor).energy<=1||(i.energy=1),t.doctor.setMood(2),t.rebuild(),n.target.active=0,n.target.countdown=1,t.audio.click2())),n.target=null},0)}},t.madmax=0,t.demad=function(e){var n,r,i;return n=t.percent.sprite.points.filter(function(t){return null!=t.mad&&t.mad>=1}),n.length||(t.madmax=0),n.length?((r=n[0]).mad<=.8||(r.mad=.8),n[0].mad-=.1,(r=n[0]).mad>=0||(r.mad=0)):t.doctor.faint&&(i=t.doctor,i.energy+=.1,i.energy<=1||(i.energy=1),1===t.doctor.energy&&(t.doctor.faint=!1)),e.preventDefault(),t.audio.click2(),!1},t.rebuild(),c=function(){return 2!==t.game.state&&3!==t.game.state||t.dialog.show===!0?!0:!1},e(function(){var e;if(!c()&&!t.dialog.tut)return Math.random()<t.config.cur.pat&&t.patient.add(1),Math.random()<t.config.cur.sup&&t.supply.active(),e=t.audio.s.bk.currentTime,t.config.cur=60>=e?t.config.setting[0]:110>=e?t.config.setting[1]:t.config.setting[2]},100),t.madspeed=.002,e(function(e){var n,r,i,a,o,s=[];if(!c()){for(t.doctor.hurting&&(t.doctor.hurting-=.2,(n=t.doctor).hurting>=0||(n.hurting=0)),t.doctor.draining&&(t.doctor.draining-=.2,(n=t.doctor).draining>=0||(n.draining=0)),r=t.percent.sprite.points.filter(function(t){return 1===t.type&&t.variant>0}),i=0,a=r.length;a>i;++i)e=r[i],e.life-=.004*e.variant,e.life<=0&&(e.life=0,t.doctor.fail(),e.variant=0);for(r=t.percent.sprite.points.filter(function(t){var e;return(2===(e=t.type)||3===e||4===e)&&t.variant>0}),o=0,i=0,a=r.length;a>i;++i)e=r[i],null==e.mad&&(e.mad=0),e.mad+=t.madspeed,e.mad>=.8&&(e.mad=1,o=1);if(o&&!t.madmax&&(t.madmax=parseInt(2*Math.random()+1)),!t.doctor.faint){for(r=t.percent.sprite.points.filter(function(t){var e;return(5===(e=t.type)||6===e||7===e||8===e)&&t.active}),i=0,a=r.length;a>i;++i)e=r[i],(null==e.countdown||e.countdown<=0)&&(e.countdown=1),e.countdown-=.025,e.countdown<=0&&(e.countdown=1,e.active=0,s.push(t.doctor.drain()));return s}}},100),t.$watch("madmax",function(t){return t?$("#wheel").css({display:"none"}):void 0}),t.hitmask={ready:!1,get:function(t,e){return this.ready?this.ctx.getImageData(t,e,1,1).data:[0,0,0,0]},resolve:function(e,n){var r,i,a;return r=this.get(e,n),i=r[0],0===i?null:(a=1===i?4*r[1]+r[2]:r[2],t.percent.sprite.points.filter(function(t){return t.type===i})[a])},init:function(){var t,e=this;return t=this.canvas=document.createElement("canvas"),t.height=576,t.width=1024,this.ctx=this.canvas.getContext("2d"),this.img=new Image,this.img.src="mask.png",this.img.onload=function(){return e.ctx.drawImage(e.img,0,0,1024,576),e.ready=!0}}},t.hitmask.init(),t.dialog={tut:!0,show:!1,idx:0,next:function(){var t=this;return n(function(){return t.main(!0)},200)},type:"",h:{i:[],t:[]},skip:function(){var r,i,a,o;for(r=0,a=(i=this.h.i).length;a>r;++r)o=i[r],e.cancel(o);for(r=0,a=(i=this.h.t).length;a>r;++r)o=i[r],n.cancel(o);return this.idx=this.step.length-2,this.clean(),t.game.start()},interval:function(t,n){var r;return r=e(t,n),this.h.i.push(r),r},timeout:function(t,e){var r;return r=n(t,e),this.h.t.push(r),r},clean:function(){var e;return delete t.mouse.forceStay,delete t.mouse.forceMood,t.dialog.tut=!1,t.mouse.unlock(),$("#score").removeClass("hint"),e=t.doctor,e.chance=5,e.hurting=0,e.faint=!1,e.energy=1,e.setMood(2),t.game.setState(2)},step:[{},{ready:!1,check:function(){return this.ready||2!==t.game.state||(t.game.state=3,this.ready=!0),this.ready},fire:function(){return t.mouse.forceStay=!1,t.mouse.forceMood=1,t.mouse.lock(),t.dialog.timeout(function(){return t.patient.add(1,1,0)},1e3),t.dialog.timeout(function(){return t.patient.add(1,2,0)},2e3),t.dialog.timeout(function(){return t.patient.add(1,3,0)},3e3)}},{ready:!1,check:function(){var e=this;return this.ready?!0:(t.percent.sprite.points.filter(function(t){return 1===t.type&&3===t.variant}).length>0&&t.dialog.timeout(function(){return e.ready=!0},1e3),!1)}},{check:function(){return!0}},{check:function(){return!0},fire:function(){return $("#finger-slide").css({display:"block",top:"33%",left:"22%"}),setTimeout(function(){return $("#finger-slide").css({display:"none"}),t.mouse.unlock()},3e3)}},{check:function(){var e,n=this;return e=0===t.percent.sprite.points.filter(function(t){return 1===t.type&&0!==t.variant}).length,e&&(t.dialog.type="mini",this.handler=t.dialog.timeout(function(){return t.doctor.fail(),n.handler=null},500)),e},fire:function(){var e;return e=t.doctor,e.chance=5,e.hurting=0,this.handler?n.cancel(this.handler):void 0}},{check:function(){return $("#score").addClass("hint"),!0},fire:function(){return $("#score").removeClass("hint")}},{mood:0,check:function(){var e=this;return null==this.handler&&(this.handler=t.dialog.interval(function(){return t.doctor.setMood(e.mood+4),t.rebuild(),e.mood=(e.mood+1)%3},500)),!0},fire:function(){return t.doctor.setMood(1),t.rebuild(),e.cancel(this.handler),t.mouse.forceStay=!0,t.patient.add(1,2,0)}},{mood:3,ready:!1,handler:null,moodHandler:null,check:function(){var e,n,r=this;return e=t.percent.sprite.points.filter(function(t){return 4===t.type&&t.variant>0}).length>0,n=t.percent.sprite.points.filter(function(t){return 1===t.type&&2===t.variant}).length>0,e&&null==this.handler&&(this.handler=t.dialog.timeout(function(){return r.ready=!0},1e3)),e||n||t.patient.add(1,2,parseInt(1+4*Math.random())),this.ready&&!this.moodHandler&&(this.moodHandler=t.dialog.interval(function(){return t.doctor.setMood(r.mood),t.rebuild(),r.mood=4-r.mood},500)),this.ready},fire:function(){return e.cancel(this.moodHandler),$("#finger-tap").css({display:"block",top:"22%",left:"68%"}),t.madspeed=.02,t.dialog.timeout(function(){return $("#finger-tap").css({display:"none"})},1300)}},{ready:!1,handler:null,check:function(){var e=this;return.02!==t.madspeed||"none"!==$("#finger-tap").css("display")||this.handler||(this.handler=t.dialog.timeout(function(){return e.ready=!0},2e3)),this.ready},fire:function(){return t.mouse.lock()}},{launched:0,supply:0,ready:!1,check:function(){var e=this;return t.madmax>=1&&0===this.launched&&(this.launched=1,$("#finger-tap").css({display:"block",top:"30%",left:"30%"}),t.madspeed=.002,t.dialog.timeout(function(){return $("#finger-tap").css({display:"none"})},1e3)),.002===t.madspeed&&t.madmax<1&&1===this.launched&&(this.launched=2,t.percent.sprite.points.filter(function(t){return 4===t.type})[0].mad=0,t.dialog.timeout(function(){return e.handler=t.dialog.interval(function(){return t.supply.active(e.supply,!1),e.supply=(e.supply+1)%4,t.supply.active(e.supply)},500),$("#arrow").css({display:"block",top:"25%",left:"35%"}),e.ready=!0},1e3)),this.ready},fire:function(){return e.cancel(this.handler),t.supply.active(0,!1),t.supply.active(1,!0),t.supply.active(2,!1),t.supply.active(3,!1),$("#arrow").css({display:"none"}),$("#finger-tap").css({display:"block",top:"7%",left:"20%"}),t.dialog.timeout(function(){return $("#finger-tap").css({display:"none"})},1e3)}},{ready:!1,handler:!1,check:function(){var e=this;return this.handler||(this.handler=t.dialog.timeout(function(){return e.ready=!0,t.supply.active(1,!1),t.doctor.setMood(7),t.rebuild(),t.doctor.energy-=.1,$("#arrow").css({display:"block",top:"10%",left:"31%"})},3e3)),this.ready},fire:function(){return $("#arrow").css({display:"none"}),t.doctor.energy=0,t.doctor.faint=!0,$("#finger-tap").css({display:"block",top:"20%",left:"30%"}),t.dialog.timeout(function(){return $("#finger-tap").css({display:"none"})},1e3)}},{ready:!1,check:function(){var e=this;return console.log("hit"),null==this.handler&&1===t.doctor.energy&&t.doctor.faint===!1&&(this.handler=t.dialog.timeout(function(){return e.ready=!0,t.dialog.type=""},1e3)),this.ready},fire:function(){return t.dialog.clean()}},{check:function(){return!1}}],main:function(t){return null==t&&(t=!1),t&&this.step[this.idx]&&this.step[this.idx].fire&&!this.step[this.idx].fired&&(this.step[this.idx].fire(),this.step[this.idx].fired=!0),!this.show||t?this.step[this.idx+1]&&this.step[this.idx+1].check()?this.toggle(this.idx+1,!0):this.toggle(0,!1):void 0},toggle:function(e,n){var r=this;return e&&(this.idx=e),setTimeout(function(){return r.show=null==n?!r.show:n,r.show?($("#dialog").fadeIn(),t.audio.menu()):$("#dialog").fadeOut()},0)}},e(function(){return t.dialog.main()},100),t.audio={s:{},names:["amb","click","count1","count2","blop","die","menu","sel","dindon","born","click2","bk"],reset:function(){var t,e,n,r,i=[];for(t=0,n=(e=this.names).length;n>t;++t)r=e[t],i.push(this.s[r].pause());return i},player:function(t){var e=this;return function(){return e.s[t].currentTime=0,e.s[t].play()}},init:function(){var t,e,n,r,i,a=[];for(t=0,n=(e=this.names).length;n>t;++t)r=e[t],i=this.s[r]=new Audio,i.src="snd/"+r+".mp3",a.push(this[r]=this.player(r));return a}},t.audio.init()}));