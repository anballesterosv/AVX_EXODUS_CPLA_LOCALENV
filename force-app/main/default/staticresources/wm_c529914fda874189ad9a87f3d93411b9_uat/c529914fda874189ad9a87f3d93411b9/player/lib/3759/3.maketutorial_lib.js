window._walkmeWebpackJP&&_walkmeWebpackJP([3,4,5],{138:function(t,e,i){(function(t){"use strict";var i=function(){function t(t,e,i){this._dataManagerWasInit=!1,this._siteConfigManager=t,this._clientOrServerStorageManager=e,this._commonUtils=i,this.AG_DATA_COOKIE_NAME=e.keysConfig.attentionGrabber.data.key}return t.prototype.updateSelection=function(t){this.selectedId=t,this.save()},t.prototype.updateEvent=function(){this._eventTimestamp=(new Date).getTime(),this.save()},t.prototype.updateUnload=function(){this.unload=1,this.save()},t.prototype.init=function(){var t=this._clientOrServerStorageManager.getData(this.AG_DATA_COOKIE_NAME),e=(new Date).getTime(),i=this._siteConfigManager.get().Settings,r=parseInt(i.AGDataVersion)||0;if(t){this._sessionTimestamp=e,this.sessionCounter=t.sc||1,this._version=this._commonUtils.isDefined(t.v)?t.v:r,this._shouldUpdateVersion=r>this._version;var a,s=t.st?Math.abs(e-t.st):0;this._commonUtils.isLocalStorageEnabled()&&(a=window.localStorage.getItem(this._clientOrServerStorageManager.keysConfig.attentionGrabber.sessionLength.key)),this._sessionLength=parseFloat(a||i.AGSL||1440),this._shouldUpdateCounter=s/6e4>this._sessionLength,this.isNewSession=this._shouldUpdateCounter||this._shouldUpdateVersion,this.sessionCounter=this._shouldUpdateVersion?1:this._shouldUpdateCounter?this.sessionCounter+1:this.sessionCounter,this._version=this._shouldUpdateVersion?r:t.v,this.selectedId=this.isNewSession?void 0:t.id,this._eventTimestamp=this.isNewSession?e:t.et,this.unload=this.isNewSession?0:t.u,this.eventTimestampDelta=this._eventTimestamp?Math.abs(e-this._eventTimestamp):0}else this.isNewSession=!0,this._sessionTimestamp=e,this.sessionCounter=1,this._version=r,this._eventTimestamp=e,this.unload=0;this._dataManagerWasInit=!0,this.save()},t.prototype.save=function(){if(!this._dataManagerWasInit)return;var t={st:this._sessionTimestamp,sc:this.sessionCounter,v:this._version,id:this.selectedId,et:this._eventTimestamp,u:this.unload};this._clientOrServerStorageManager.saveData(this.AG_DATA_COOKIE_NAME,t,this._clientOrServerStorageManager.keysConfig.attentionGrabber.data.expiry)},t}();e.AttentionGrabberDataManager=i,t.register("AttentionGrabberDataManager").asCtor(i).dependencies("SiteConfigManager, ClientOrServerStorageManager, CommonUtils")}).call(e,i(2))},139:function(t,e,i){(function(t){"use strict";var r=function(){function e(t,e,i,r,a,s,n,o){this.commonUtils=s,this.NEW_CONTENT_PRIORITY=1e3,this._conditionTreeEvaluator=t,this._clientOrServerStorageManager=i,this._publishDataManager=r,this._logger=a,this._agDataManager=e}return e.prototype.init=function(t){if(!t.config||!t.player)return;this._config=t.config,this._player=t.player,this._menu=t.menu;var e=this._config.Settings.AG,i=this._config.Settings.AGs;if(i&&i.length>0)this._agDataManager.init(),this.initAllAGs(i);else if(e){var r=this.create(t);r.setupAttenGrab()}},e.prototype.reset=function(){this._agData=this._agClass=this._config=this._player=this._menu=void 0},e.prototype.initAllAGs=function(t){if(this._agDataManager.isNewSession){1===this._agDataManager.sessionCounter&&this._publishDataManager.saveDataVersion();var e=this.getPotentialAGsForNewSession(t);e=e.sort(function(t,e){return t.Priority-e.Priority}),this.updateAGForNewSession(e)}else this.updateAGForOldSession(t);this._agData?(this._logger.customerLog("Attention grabber - name: "+this._agData.Name+", settings:",3),this._logger.customerLog(this._agData.Settings,3)):this._logger.customerLog("Attention grabber: not selected",3);var i="Attention grabber data: session counter = "+this._agDataManager.sessionCounter+", selected AG = "+this._agDataManager.selectedId+", unload AG = "+this._agDataManager.unload+", event timestamp delta = "+this._agDataManager.eventTimestampDelta/1e3+"s, session = "+this._agDataManager.isNewSession;this._logger.customerLog(i,4)},e.prototype.getPotentialAGsForNewSession=function(t){for(var e=[],i=this._agDataManager.sessionCounter,r=0;r<t.length;r++){var a=t[r],s=a.Settings;this.shouldPlayAtSession(i,s)&&(parseInt(s.newContent)?this._publishDataManager.hasNewDeployables()&&(a.Priority-=this.NEW_CONTENT_PRIORITY,e.push(a)):e.push(a))}return e},e.prototype.updateAGForNewSession=function(t){for(var e=0;e<t.length;e++){var i=t[e],r=i.Settings;if(!r.conditions)return this._agData=i,void this._agDataManager.updateSelection(i.Id);var a=this._conditionTreeEvaluator.evaluate(r.conditions);if(a)return this._agData=i,void this._agDataManager.updateSelection(i.Id)}},e.prototype.updateAGForOldSession=function(t){for(var e=this._agDataManager.sessionCounter,i=0;i<t.length;i++){var r=t[i],a=r.Settings;if(r.Id==this._agDataManager.selectedId){var a=r.Settings;if(this.shouldPlayAtSession(e,a)&&this.shouldReplayAG(a))if(a.conditions){var s=this._conditionTreeEvaluator.evaluate(a.conditions);s?(this._agData=r,this._agDataManager.updateSelection(r.Id)):this._logger.customerLog("Attention grabber conditions are not satisfied",5)}else this._agData=r,this._agDataManager.updateSelection(r.Id);return}}},e.prototype.shouldPlayAtSession=function(t,e){if(!e||!this.commonUtils.isDefined(e.session)||!this.commonUtils.isDefined(e.interval))return!1;if(t<e.session)return!1;if(t==e.session)return!0;if(0==e.interval)return!1;if((t-e.session)%e.interval==0)return!0;return!1},e.prototype.shouldReplayAG=function(t){if(this._agDataManager.unload)return!1;if(!t)return!1;var e=this._agDataManager.eventTimestampDelta,i=parseInt(t.replay);if(!i||!e)return!1;var r=60*i*1e3;return e>r?t.delay=0:t.delay=(r-e)/1e3,!0},e.prototype.load=function(){var t=this;if(!this._agData)return;var e={config:this._config,player:this._player,menu:this._menu,agData:this._agData};i.e(4,function(i){(function(r){var a=[i(140)];(function(){t._agClass=r.create("AttentionGrabber",e),t._agClass.setupAttenGrab()}).apply(null,a)}).call(this,i(2))})},e.prototype.remove=function(t){if(!this._agClass)return void(t&&t());this._agDataManager.updateUnload(),this._agClass.remove(t)},e.prototype.create=function(e){return this._config=e.config,this._player=e.player,this._agClass=t.create("AttentionGrabber",e),this._agClass},e.prototype.getImageAG=function(e){return this._config=e.config,this._player=e.player,this._agClass=t.create("ImageAttentionGrabber",e),this._agClass},e}();e.AttentionGrabberManager=r,t.register("AttentionGrabberManager").asCtor(r).dependencies("ConditionTreeEvaluator, AttentionGrabberDataManager, ClientOrServerStorageManager, PublishDataManager, Logger, CommonUtils, SiteConfigManager, Consts")}).call(e,i(2))},140:function(t,e,i){(function(t){i(141),i(142),i(144),i(145),i(146),i(147),i(148),i(149),i(150),i(143),i(151),i(152),t.register("AttentionGrabber").asFunction(r).asProto();function r(e){var i;if(e.agData)i=e.agData.ClassType;else{var r=e.config.Settings.AG;r&&(i=r.type)}i=i||0;var a={0:"ImageAttentionGrabber",1:"OldSwooshAttentionGrabber",2:"SwooshAttentionGrabber",3:"MenuOverviewAttentionGrabber",4:"TickerAttentionGrabber",5:"CustomTextAttentionGrabber",6:"CustomImageAttentionGrabber","3.sub":"MenuOverviewSubAttentionGrabber"},s=a[i];return t.create(s,e)}e.AttentionGrabber=r}).call(e,i(2))},141:function(t,e,i){(function(t){"use strict";var i=function(){function e(e,i,r,a,s,n,o,h,l){this._stopAnimation=!1,this.POSITION="TrianglePosition",this._lib=e,this._commonUtils=i,this._timerManager=r,this._endUsersManager=a,this._auditSourceManager=s,this._hostData=n,this._wmAjax=o,this._safeFullUrlProvider=h,this._storageKeysConfigurations=t.get("StorageKeysConfigurations"),this._config=l.config,this._player=l.player,this._menu=l.menu,this._logger=t.get("Logger"),this._topContainer=t.get("TopContainerProvider").getTopContainer(),l.agData?(this._data=l.agData,this._settings=l.agData.Settings,this._agId=this._data.Id,this._dataManager=t.get("AttentionGrabberDataManager")):(this._oldAG=!0,this._oldAGData=this._commonUtils.getSettingsValue(this._config.Settings,"AG",!1),this._oldAGData&&(this._settings={},this._oldAGData.delay&&(this._settings.delay=this._oldAGData.delay),this._oldAGData.timeout&&(this._settings.duration=this._oldAGData.timeout),this._oldAGData.repeat&&(this._settings.repeat=this._oldAGData.repeat)))}return e.prototype.drawAttentionGrabber=function(){if(this._logger.customerLog("Start drawing attention grabber",5),this._replayTimeoutHandler&&this._replayTimeoutHandler.clear(),this._attentionGrabber=this.getHtml(),!this._attentionGrabber)return;this._attentionGrabberWrapper=wmjQuery("<div id='walkme-attengrab' class='walkme-to-destroy' style='display: none;'/>"),this._attentionGrabberWrapper.append(this._attentionGrabber),this._topContainer.append(this._attentionGrabberWrapper),this._lib.getUiUtils().setLangAttribute(this._attentionGrabberWrapper),this.updateEvent();var t=wmjQuery.proxy(function(){this.postDrawing(),this.hideAfterTimeout(),this._commonUtils.handleAccessibleElement(this._attentionGrabberWrapper,"button")},this);this._timerManager.libSetTimeout(t,100)},e.prototype.getHtml=function(){},e.prototype.postDrawing=function(){},e.prototype.hideAfterTimeout=function(){var t=parseInt(this._settings.duration);if(!t)return;var e=wmjQuery.proxy(function(){this.hide(),this._stopAnimation=!0},this);this._hideTimeoutHandler=this._timerManager.libSetTimeout(e,1e3*t)},e.prototype.isSupportedByBrowser=function(){return!0},e.prototype.setupAttenGrab=function(){if(!this.isSupportedByBrowser())return;if(!this._settings||wmjQuery.isEmptyObject(this._settings))return;if(this.innerSetup()===!1)return;if(this._settings.repeat){var e=this._storageKeysConfigurations.attentionGrabber.repeat.key,i=t.get("AutoStartManager").checkRepeatCookie(e,this._settings.repeat);if(!i.shouldStart)return;i.store()}var r=wmjQuery.proxy(function(){this.drawAttentionGrabber()},this);this._delayTimeoutHandler=this._timerManager.libSetTimeout(r,1e3*parseFloat(this._settings.delay))},e.prototype.innerSetup=function(){return!0},e.prototype.remove=function(t){try{this._logger.customerLog("Remove attention grabber",5),this._attentionGrabberWrapper&&this._attentionGrabberWrapper.remove(),this.clearTimers(),this.updateEvent(),t&&t()}catch(e){t&&t()}},e.prototype.hide=function(){this.remove(),this.replay()},e.prototype.updateEvent=function(){this._dataManager&&this._dataManager.updateEvent()},e.prototype.replay=function(){var t=parseInt(this._settings.replay);if(!t)return;this._logger.customerLog("Replay attention grabber",5);var e=wmjQuery.proxy(function(){this.drawAttentionGrabber()},this);this._replayTimeoutHandler=this._timerManager.libSetTimeout(e,1e3*t*60)},e.prototype.getDirection=function(){return this._config.Direction},e.prototype.getDefaultOrFirstTab=function(){for(var e=t.get("UiDataProvider").uiObjectsTree(),i=0;i<e.length;i++)if(e[i].properties().hasProperty("default"))return e[i];for(var i=0;i<e.length;i++)if(e[i].properties().hasProperty("visible"))return e[i]},e.prototype.clearTimers=function(){this._delayTimeoutHandler&&this._delayTimeoutHandler.clear(),this._replayTimeoutHandler&&this._replayTimeoutHandler.clear(),this._hideTimeoutHandler&&this._hideTimeoutHandler.clear()},e}();e.AttentionGrabberBase=i,t.register("AttentionGrabberBase").asCtor(i).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(2))},142:function(t,e,i){(function(t,r){"use strict";var a=i(143),s=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l){e.call(this,t,i,r,a,s,n,o,h,l),this._oppositeDirections={left:"right",right:"left",bottom:"top",top:"bottom"}}return i.prototype.getTemplateData=function(){var t=r.get("LanguageManager");return{title:this.getBalloonTitle(),text:this.getBalloonText(),position:this.getOppositeDirection(this._playerMajorPosition),buttons:this._settings.buttons,direction:this.getDirection(),language:t.getCurrentLanguage()}},i.prototype.getBalloonText=function(){return""},i.prototype.getBalloonTitle=function(){return},i.prototype.setLogicCss=function(){e.prototype.setLogicCss.call(this),this._attentionGrabberWrapper.css("direction",this.getDirection())},i.prototype.bindEvents=function(){e.prototype.bindEvents.call(this);var t=wmjQuery.proxy(this.remove,this);this._xBtn=wmjQuery(".wm-x-button",this._attentionGrabberWrapper),this._xBtn.click(function(){t()})},i.prototype.getHorizontalOffset=function(){return wmjQuery(".wm-outer-arrow",this._attentionGrabberWrapper).outerWidth()},i.prototype.getVerticalOffset=function(){return wmjQuery(".wm-outer-arrow",this._attentionGrabberWrapper).outerHeight()},i.prototype.animate=function(){var t=this._attentionGrabberWrapper,e=this._playerMajorPosition,i=parseInt(t.css(e)),r=i+30+"px",a=this._stopAnimation,s=0,n=this._timerManager.libSetTimeout;function o(){if(1==s)return s=0,void n(function(){o()},3e3);s++;var h={};h[e]=r,t.animate(h,{easing:"swing",duration:700,complete:function(){n(function(){var r={};r[e]=i+5+"px",t.animate(r,{easing:"easeOutBounce",duration:700,complete:function(){a||n(function(){o()},100)}})},100)}})}o()},i.prototype.getOppositeDirection=function(t){return this._oppositeDirections[t]},i.prototype.remove=function(t){try{if(this._attentionGrabberWrapper){this._attentionGrabberWrapper.off("click"),this._xBtn&&this._xBtn.off("click");var i=wmjQuery.proxy(e.prototype.remove,this);this._attentionGrabberWrapper.stop(!0,!0);var r={opacity:0};this._hostData.isIE(8)?e.prototype.remove.call(this,t):this._attentionGrabberWrapper.animate(r,{duration:300,complete:function(){i(t)}})}else e.prototype.remove.call(this,t)}catch(a){e.prototype.remove.call(this,t)}},i}(a.TemplateAttentionGrabber);e.BalloonAttentionGrabber=s,r.register("BalloonAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},143:function(t,e,i){(function(t,r){"use strict";var a=i(141),s=function(e){t(i,e);function i(t,i,a,s,n,o,h,l,p){e.call(this,t,i,a,s,n,o,h,l,p),this.hostData=o,this.positions=["left","right","top","bottom"],this._templateId=this._data.UITemplateId,this._templateVersion=this._data.UITemplateVersion,this._templateVariations=[];for(var u in this._data.UIVariationsIds)this._templateVariations.push(r.get("UIVariations").get(this._data.UIVariationsIds[u]));this._data.Settings.customVariation&&this._templateVariations.push(this._data.Settings.customVariation),this._setPositionProxy=wmjQuery.proxy(function(){this.setPosition()},this),this._playerMajorPosition=this._config[this.POSITION].slice(0,this._config[this.POSITION].indexOf("-")),this._agPlayInitiator=r.get("Consts").STEP_PLAY_INITIATOR_ENUM.ATTENTION_GRABBER}return i.prototype.isSupportedByBrowser=function(){return!this._hostData.isIE(7)},i.prototype.getHtml=function(){return r.get("TemplatesFactory").get(this._templateId,this._templateVersion,this._templateVariations,this.getTemplateData())},i.prototype.getTemplateData=function(){return{}},i.prototype.getHorizontalOffset=function(){return 0},i.prototype.getVerticalOffset=function(){return 0},i.prototype.animate=function(){},i.prototype.postDrawing=function(){this.addMainClass(),this._attentionGrabber.show(),this._attentionGrabberWrapper.show(),this.setPosition(),this.bindEvents(),this.animate()},i.prototype.addMainClass=function(){this._attentionGrabber.addClass("wm-ag-"+this._mainClass)},i.prototype.copyCssProperties=function(){for(var t=0;t<this.positions.length;t++)this._attentionGrabberWrapper.css(this.positions[t],this.getCssPosition(this._player,this.positions[t])),this._attentionGrabberWrapper.css("margin-"+this.positions[t],this._player.css("margin-"+this.positions[t]))},i.prototype.fixCssMargins=function(t,e){var i=parseFloat(this._attentionGrabberWrapper.css("margin-left"))||0,r=parseFloat(this._attentionGrabberWrapper.css("margin-right"))||0,a=parseFloat(this._attentionGrabberWrapper.css("margin-top"))||0,s=parseFloat(this._attentionGrabberWrapper.css("margin-bottom"))||0;this._attentionGrabberWrapper.css("margin-left",i+t+"px").css("margin-right",r+t+"px"),this._attentionGrabberWrapper.css("margin-top",a+e+"px").css("margin-bottom",s+e+"px")},i.prototype.getCssPosition=function(t,e){var i,r=t[0].style[e];i=this.hostData.isIE(8)?t[0].currentStyle[e]:t.css(e),t.important(e,"auto");var a=t.css(e);if(t.important(e,""),r&&(t[0].style[e]=r),i!=a)return i;return"auto"},i.prototype.setLogicCss=function(){this._attentionGrabberWrapper.css("z-index"," 2147483647"),this._attentionGrabberWrapper.css("cursor","pointer")},i.prototype.bindEvents=function(){wmjQuery(window).resize(this._setPositionProxy);var t=wmjQuery.proxy(function(){var t={type:this._agPlayInitiator};this._menu.toggle({initiator:t})},this);this._attentionGrabberWrapper.click(t)},i.prototype.unbindEvents=function(){wmjQuery(window).off("resize",this._setPositionProxy)},i.prototype.setPosition=function(){this._attentionGrabberWrapper.css("position","fixed"),this.setLogicCss();var t,e;"left"==this._playerMajorPosition||"right"==this._playerMajorPosition?(t=this._player.outerWidth()+this.getHorizontalOffset(),e=(this._player.outerHeight()-this._attentionGrabber.outerHeight())/2):"top"!=this._playerMajorPosition&&"bottom"!=this._playerMajorPosition||(t=(this._player.outerWidth()-this._attentionGrabber.outerWidth())/2,e=this._player.outerHeight()+this.getVerticalOffset()),this.copyCssProperties(),this.fixCssMargins(t,e)},i.prototype.remove=function(t){try{this.unbindEvents(),e.prototype.remove.call(this,t)}catch(i){e.prototype.remove.call(this,t)}},i}(a.AttentionGrabberBase);e.TemplateAttentionGrabber=s,r.register("TemplateAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},144:function(t,e,i){(function(t,r){"use strict";var a=i(143),s=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l,p,u,g){e.call(this,t,i,r,a,s,n,o,h,g),this.commonEvents=p,this.consts=u,this._mainClass="custom-image",this._resourceManager=l}return i.prototype.getHtml=function(){var t=this._resourceManager.getResourcePath(this._settings.image.url);if(this.isHttpOverHttps(t))return this._logger.customerLog("Attention Grabber - Could not load Custom Image because source is http over https",3),this.commonEvents.raiseEvent(this.consts.EVENTS.AttentionGrabberInsecure,{name:"Custom Image"}),null;var e=r.get("TemplatesFactory").get(this._templateId,this._templateVersion,this._templateVariations,{src:t});return e.height(this._settings.image.height).width(this._settings.image.width),e},i.prototype.setLogicCss=function(){e.prototype.setLogicCss.call(this),this._attentionGrabberWrapper.height(this._settings.image.height).width(this._settings.image.width)},i.prototype.isHttpOverHttps=function(t){if(!t)return!1;if(0!=window.location.href.indexOf("https://"))return!1;return t.indexOf("https://")==-1},i}(a.TemplateAttentionGrabber);e.CustomImageAttentionGrabber=s,r.register("CustomImageAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, ResourceManager, CommonEvents, Consts")}).call(e,i(1),i(2))},145:function(t,e,i){(function(t,r){"use strict";var a=i(142),s=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l){e.call(this,t,i,r,a,s,n,o,h,l),this._mainClass="custom-text"}return i.prototype.getBalloonText=function(){return this._settings.text||""},i.prototype.setLogicCss=function(){e.prototype.setLogicCss.call(this);var t=wmjQuery(".wm-title",this._attentionGrabber);t.css("width","auto")},i}(a.BalloonAttentionGrabber);e.CustomTextAttentionGrabber=s,r.register("CustomTextAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},146:function(t,e,i){(function(t,r){"use strict";var a=i(141),s=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l){e.call(this,t,i,r,a,s,n,o,h,l),this._drawAGWaitForImagesFailCount=0,this._oldAG&&(this._oldAGData.id&&(this._settings.id=this._oldAGData.id),this._oldAGData.filename&&(this._settings.filename=this._oldAGData.filename),this._oldAGData.hOffset&&(this._settings.hOffset=this._oldAGData.hOffset),this._oldAGData.vOffset&&(this._settings.vOffset=this._oldAGData.vOffset))}return i.prototype.getHtml=function(){return wmjQuery("<img src='"+this._settings.filename+"' />")},i.prototype.innerSetup=function(){if(this._settings.filename&&(this._settings.filename=this._lib.ResourceManager.getResourcePath(this._settings.filename)),parseInt(this._settings.id)==-1)return!1;return!0},i.prototype.postDrawing=function(){this.drawAGWaitForImages()},i.prototype.drawAGWaitForImages=function(){var t=wmjQuery.proxy(this.imageNotLoadedCases,this);if(i(this._player)){if(this._drawAGWaitForImagesFailCount++,this._drawAGWaitForImagesFailCount>10)return;var e=wmjQuery.proxy(this.drawAGWaitForImages,this);this._timerManager.libSetTimeout(function(){e()},500)}else this.drawAGPostLoad();function i(e){var i=t(),r="1"==e.attr("data-inanimation");return i||r}},i.prototype.drawAGPostLoad=function(){var t="0px",e="0px",i="0px",r="0px",a="auto",s="auto",n="auto",o="auto",h=parseInt(this._settings.hOffset),l=parseInt(this._settings.vOffset),p=(this._player.width()-this._attentionGrabberWrapper.width())/2,u=(this._player.height()-this._attentionGrabberWrapper.height())/2;n=this.handlePosition(n,"bottom",u,l),a=this.handlePosition(a,"top",u,l),s=this.handlePosition(s,"right",p,h),o=this.handlePosition(o,"left",p,h),this._config[this.POSITION].indexOf("center")>-1&&(o="50%",r=this.buildPosition(r,"margin-left",p,h),r=this.dynamicSizeHandler("width",r)),this._config[this.POSITION].indexOf("middle")>-1&&(a="50%",t=this.buildPosition(t,"margin-top",u,l),t=this.dynamicSizeHandler("height",t)),this._attentionGrabberWrapper.css({position:"fixed",top:a,right:s,bottom:n,left:o,"margin-top":t,"margin-right":e,"margin-bottom":i,"margin-left":r}),this._attentionGrabberWrapper.show()},i.prototype.handlePosition=function(t,e,i,r){return this._config[this.POSITION].indexOf(e)>-1&&(t=this.buildPosition(t,e,i,r)),t},i.prototype.buildPosition=function(t,e,i,r){return t=parseFloat(this._player.css(e).replace("px","")),t+=i,t+=r,t+="px"},i.prototype.dynamicSizeHandler=function(t,e){return this._player.hasClass("walkme-dynamic-size")&&(e=parseFloat(e.replace("px",""))+this._player.css(t).replace("px","")/2*-1),e},i.prototype.imageNotLoadedCases=function(){return 0==this._player.width()||28==this._player.width()||0==this._attentionGrabberWrapper.width()||28==this._attentionGrabberWrapper.width()||24==this._attentionGrabberWrapper.width()&&24==this._attentionGrabberWrapper.width()},i}(a.AttentionGrabberBase);e.ImageAttentionGrabber=s,r.register("ImageAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},147:function(t,e,i){(function(t,r){"use strict";var a=i(141),s=function(e){t(i,e);function i(t,i,a,s,n,o,h,l,p){e.call(this,t,i,a,s,n,o,h,l,p),this._balloonsData={0:{classType:"3.sub",title:"Meet WalkMe!",text:"Your New Personal Assistant.",buttonText:"Start",position:"bottom-center",firstBalloon:!0},1:{classType:"3.sub",text:"The WalkMe menu is the place to get all the help you might need.",boldText:'Click "Next" and take a look...',buttonText:"Next",position:"bottom-center",delay:1,marginBottom:3},2:{classType:"3.sub",text:"Here you can select your preferred language.",boldText:'Click "Next" to continue...',buttonText:"Next",position:"bottom-center",attachedToElementSelector:"#walkme-languages",moveArrow:!0},3:{classType:"3.sub",text:"Quickly find answers to your support issue by using the search bar.",boldText:'Click "Next" to continue...',buttonText:"Next",position:"right-middle",attachedToElementSelector:".walkme-search-box-container",marginRight:12},4:{classType:"3.sub",text:"All the Walk-Thrus and help resources are located here, click them to start your online guidance.",boldText:'Click "Next" to continue...',buttonText:"Next",position:"right-middle",attachedToElementSelector:".walkme-deployables-list .walkme-tab .walkme-deployable",marginRight:14},5:{classType:"3.sub",text:"Couldn't find what you want? this link takes you to the support page.",boldText:"To learn more about WalkMe, click here.",buttonText:"Next",position:"bottom-center",attachedToElementSelector:".walkme-open-ticket",moveArrow:!0},6:{classType:"3.sub",title:"Thank You!",text:"We're here to help.",buttonText:"Done",position:"bottom-center",marginBottom:3}},this._stepIndex=0,this._themeVariation=this._data.ExtraUIVariationsIds[0],this._balloonsData[0].position=this._config[this.POSITION],this._balloonsData[0].delay=this._settings.delay,this._agPlayInitiator=r.get("Consts").STEP_PLAY_INITIATOR_ENUM.ATTENTION_GRABBER;var u=wmjQuery.proxy(this.updateJqueryMenu,this);this._menu.bind("build-menu-end",function(t,e){u(e.menu)})}return i.prototype.updateJqueryMenu=function(t){this._jQueryMenu=t},i.prototype.createAg=function(t,e){var i=wmjQuery.proxy(this.showNextBalloon,this),a=wmjQuery.proxy(function(){var t=wmjQuery.proxy(function(){if(i(),1==this._stepIndex){var t={type:this._agPlayInitiator};WalkMePlayerAPI.toggleMenu(t)}},this);n.remove(t)},this),s={config:{Direction:this._config.Direction},player:t,menu:this._menu,onClickFunc:a,agData:{Id:e.firstBalloon?this._agId:null,ClassType:e.classType,UITemplateId:this._data.UITemplateId,UITemplateVersion:this._data.UITemplateVersion,UIVariationsIds:[this._themeVariation,this._data.ExtraUIVariationsIds[this._stepIndex+1]],Settings:{delay:e.delay,text:e.text,title:e.title,boldText:e.boldText,buttons:[{text:e.buttonText}],firstBalloon:e.firstBalloon,attachedToElementSelector:e.attachedToElementSelector,jQueryMenu:this._jQueryMenu,moveArrow:e.moveArrow,marginRight:e.marginRight,marginBottom:e.marginBottom}}};s.config[this.POSITION]=e.position;var n=r.create("AttentionGrabber",s);this._currentAg=n,n.setupAttenGrab()},i.prototype.showNextBalloon=function(){if(this._stopPlaying)return;if(this._stepIndex++,!this._balloonsData[this._stepIndex])return;if(!this.shouldPlay())return void this.showNextBalloon();if(this._jQueryMenu)this.createAg(this._jQueryMenu,this._balloonsData[this._stepIndex]);else{var t=wmjQuery.proxy(function(t){this._jQueryMenu=t,this.createAg(t,this._balloonsData[this._stepIndex])},this);this._menu.bind("on-open-end",function(e,i){e.target.unbind("on-open-end"),t(i.menu)})}},i.prototype.shouldPlay=function(){var t=this._balloonsData[this._stepIndex].attachedToElementSelector;if(!t)return!0;return wmjQuery(t+":visible",this._jQueryMenu).length>0},i.prototype.setupAttenGrab=function(){if(!this.isWalkthrusTab())return;if("iOS"==this._hostData.os.name||"Android"==this._hostData.os.name)return;var t=wmjQuery.proxy(this.stopAll,this);this._menu.bind("on-close-begin",function(e){t()}),this.createAg(this._player,this._balloonsData[0])},i.prototype.isWalkthrusTab=function(){var t=this.getDefaultOrFirstTab(),e=t.properties().getAll();return wmjQuery.inArray("contains-walkthru",e)>-1},i.prototype.stopAll=function(){this._stopPlaying=!0,this._currentAg.remove()},i.prototype.remove=function(t){this._currentAg&&this._currentAg.remove(),e.prototype.remove.call(this,t)},i}(a.AttentionGrabberBase);e.MenuOverviewAttentionGrabber=s,r.register("MenuOverviewAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},148:function(t,e,i){(function(t,e){"use strict";var r=i(145),a=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l){e.call(this,t,i,r,a,s,n,o,h,l),this._mainClass="menu-overview",this._arrowOffset=0,this._onClickFunc=l.onClickFunc}return i.prototype.getTemplateData=function(){return{title:this._settings.title,"bold-text":this._settings.boldText,text:this._settings.text,position:this.getOppositeDirection(this._playerMajorPosition),buttons:this._settings.buttons}},i.prototype.setLogicCss=function(){e.prototype.setLogicCss.call(this),this.moveArrow(),this._data.Settings.firstBalloon||this._attentionGrabberWrapper.css("cursor","auto")},i.prototype.moveArrow=function(){if(this._data.Settings.moveArrow){var t=wmjQuery(".wm-outer-arrow",this._attentionGrabberWrapper),e=wmjQuery(".wm-inner-arrow",this._attentionGrabberWrapper),i=t.offset().left;t.css("left");t.css("left","85%"),e.css("left","85%");var r=t.offset().left,a=r-i;this._arrowOffset=a,this._data.Settings.moveArrow=!1}},i.prototype.bindEvents=function(){e.prototype.bindEvents.call(this),this._attentionGrabberWrapper.off("click"),wmjQuery(".wm-button",this._attentionGrabberWrapper).click(this._onClickFunc),this._fixPositionProxy=wmjQuery.proxy(this.fixPosition,this),wmjQuery(window).resize(this._fixPositionProxy),this._data.Settings.firstBalloon&&this._attentionGrabberWrapper.click(this._onClickFunc)},i.prototype.unbindEvents=function(){e.prototype.unbindEvents.call(this),wmjQuery(window).off("resize",this._fixPositionProxy)},i.prototype.animate=function(){this.fixPosition(),this._data.Settings.firstBalloon&&e.prototype.animate.call(this)},i.prototype.fixPosition=function(){var t=this._attentionGrabberWrapper.css("margin-bottom"),e=this._attentionGrabberWrapper.css("margin-right"),i=this._data.Settings.marginRight||0,r=this._data.Settings.marginBottom||0;if(this._data.Settings.attachedToElementSelector){var a=this._data.Settings.jQueryMenu,s=wmjQuery(this._data.Settings.attachedToElementSelector,a),n=s.offset().left-a.offset().left,o=s.offset().top-a.offset().top;if("bottom"==this._playerMajorPosition){var h=(this._attentionGrabberWrapper.width(),a.width()),l=this._attentionGrabberWrapper.css("margin-bottom"),p=s.width(),u=(s.css("margin-right"),s.css("margin-top"),parseFloat(e)+h/2-n-p/2+this._arrowOffset+i);this._attentionGrabberWrapper.css("margin-right",u+"px").css("margin-bottom",parseFloat(l)-o+r+"px")}else{var g=a.height(),c=(a.css("border-left-width"),s.css("margin-right"),s.height()),u=parseFloat(t)+g/2-o-c/2+r;this._attentionGrabberWrapper.css("margin-right",parseFloat(e)-n+i+"px").css("margin-bottom",u+"px")}}else this._attentionGrabberWrapper.css("margin-right",parseFloat(e)+i+"px").css("margin-bottom",parseFloat(t)+r+"px")},i}(r.CustomTextAttentionGrabber);e.register("MenuOverviewSubAttentionGrabber").asCtor(a).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},149:function(t,e,i){(function(t,r){"use strict";var a=i(141),s=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l){e.call(this,t,i,r,a,s,n,o,h,l),this._defaultValues={animationDuration:700},this._oldAG&&this._oldAGData.settings&&(this._oldAGData.settings.width&&(this._settings.width=this._oldAGData.settings.width),this._oldAGData.settings.right&&(this._settings.right=this._oldAGData.settings.right),this._oldAGData.settings.deg&&(this._settings.deg=this._oldAGData.settings.deg),this._oldAGData.settings.dir&&(this._settings.dir=this._oldAGData.settings.dir,this._direction=this._oldAGData.settings.dir),this._oldAGData.settings.opacity&&(this._settings.opacity=this._oldAGData.settings.opacity))}return i.prototype.isSupportedByBrowser=function(){return!this._hostData.isIE(9,"lte")},i.prototype.getHtml=function(){var t,e;this.isHorizental()?(t=this._settings.width+"px",e="130%"):(e=this._settings.width+"px",t="130%");var i=this._settings.opacity,r=this._settings.deg;return wmjQuery("<div class='wm-ag-swoosh' style='width: "+t+"; height:"+e+"; position: absolute; top:-6px; right: -6px; background-color: transparent !important; "+this.getRotateCss(r)+this.getBackgoundCss(i)+"'/>")},i.prototype.postDrawing=function(){var t=this._settings.right;this._attentionGrabberWrapper.detach().appendTo(this._player);var e=this.isHorizental()?"width":"height",i=this._player.css(e);this._attentionGrabberWrapper.css({position:"absolute",overflow:"hidden",width:"100%",height:"100%","z-index":this._player.css("z-index"),
right:"0",bottom:"auto",top:"0"}).important("background","none"),this._attentionGrabber.show(),this._attentionGrabberWrapper.show();var r=this.getProperty("animationDuration");this.animate(i,t,r)},i.prototype.animate=function(t,e,i){var r=this._attentionGrabber,a=this.isHorizental()?"right":"top",s=this._timerManager;r.css(a,e+"px");var n=1.3*parseFloat(t)+"px";function o(){var t={};t[a]=n,r.animate(t,i);var h=this._stopAnimation;s.setWalkmeTimeout(function(){var t={};t[a]=e+"px",r.animate(t,i)},1e3),h||s.setWalkmeTimeout(o,4e3)}o()},i.prototype.isHorizental=function(){return"hoz"==this._direction},i.prototype.getProperty=function(t){return this._settings[t]||this._defaultValues[t]},i.prototype.getBackgoundCss=function(t){return"background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIxMDAlIiB5Mj0iMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2ZmZmZmZiIgc3RvcC1vcGFjaXR5PSIwIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjUwJSIgc3RvcC1jb2xvcj0iI2ZmZmZmZiIgc3RvcC1vcGFjaXR5PSIwLjkxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNmZmZmZmYiIHN0b3Atb3BhY2l0eT0iMCIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);background: -moz-linear-gradient(left,  rgba(255,255,255,0) 0%, rgba(255,255,255,"+t+") 50%, rgba(255,255,255,0) 100%);background: -webkit-gradient(linear, left top, right top, color-stop(0%,rgba(255,255,255,0)), color-stop(50%,rgba(255,255,255,"+t+")), color-stop(100%,rgba(255,255,255,0)));background: -webkit-linear-gradient(left,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);background: -o-linear-gradient(left,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);background: -ms-linear-gradient(left,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);background: linear-gradient(to right,  rgba(255,255,255,0) 0%,rgba(255,255,255,"+t+") 50%,rgba(255,255,255,0) 100%);"},i.prototype.getRotateCss=function(t){return"transform: rotate("+t+"deg); -moz-transform:rotate("+t+"deg); -webkit-transform:rotate("+t+"deg); -o-transform:rotate("+t+"deg);  -ms-transform:rotate("+t+"deg);"},i}(a.AttentionGrabberBase);e.OldSwooshAttentionGrabber=s,r.register("OldSwooshAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},150:function(t,e,i){(function(t,r){"use strict";var a=i(143),s=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l){e.call(this,t,i,r,a,s,n,o,h,l),this._mainClass="ag",this._animationDuration=this._settings.animationDuration||700}return i.prototype.isSupportedByBrowser=function(){return!this._hostData.isIE(9,"lte")},i.prototype.postDrawing=function(){this._attentionGrabberWrapper.detach().appendTo(this._player),this._attentionGrabberWrapper.css({position:"absolute",overflow:"hidden",width:"100%",height:"100%","z-index":this._player.css("z-index"),right:"0",bottom:"auto",top:"0"}).important("background","none"),this._attentionGrabber.show(),this._attentionGrabberWrapper.show(),this.animate()},i.prototype.animate=function(){var t=this._attentionGrabber,e=this._animationDuration,i=this._timerManager,r=this.isHorizental(),a=r?"right":"top",s="-60px";t.css(a,s);var n=r?"width":"height",o=1.3*parseFloat(this._player.css(n))+"px",h=this._stopAnimation;this.initAnimationProperties(r);function l(){var r={};r[a]=o,t.animate(r,e),i.setWalkmeTimeout(function(){var i={};i[a]=s,t.animate(i,e)},1e3),h||i.setWalkmeTimeout(l,4e3)}l()},i.prototype.initAnimationProperties=function(t){t?this.setInitCss("15deg","50px","130%"):this.setInitCss("105deg","130%","50px")},i.prototype.setInitCss=function(t,e,i){this._attentionGrabber.css({height:i,width:e,transform:"rotate("+t+")","-moz - transform":"rotate("+t+")","-webkit - transform":"rotate("+t+")","-o - transform":"rotate("+t+")","-ms - transform":"rotate("+t+")"})},i.prototype.isHorizental=function(){return this._player.width()>this._player.height()},i}(a.TemplateAttentionGrabber);e.SwooshAttentionGrabber=s,r.register("SwooshAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider")}).call(e,i(1),i(2))},151:function(t,e,i){(function(t,r){"use strict";var a=i(142),s=function(e){t(i,e);function i(t,i,r,a,s,n,o,h,l,p){e.call(this,t,i,r,a,s,n,o,h,p),this.htmlDecoder=l,this._mainClass="ticker",this._textItems=[],this.MAX_DEPLOYABLES_TO_SHOW=5;var u=this.getDefaultOrFirstTab();if(u)for(var g=u.children(),c=0,m=0;m<g.length;m++){var d=g[m];if(d.properties().hasProperty("visible")&&(this._textItems.push(d.name()),c++),c==this.MAX_DEPLOYABLES_TO_SHOW)break}this._currentDeployableIndex=0}return i.prototype.setupAttenGrab=function(){if(0===this._textItems.length)return;e.prototype.setupAttenGrab.call(this)},i.prototype.getBalloonTitle=function(){return"Help me with..."},i.prototype.getBalloonText=function(){return this._textItems[this._currentDeployableIndex]},i.prototype.getDeployableText=function(){var t=this._textItems[this._currentDeployableIndex];return this._currentDeployableIndex<Math.min(this.MAX_DEPLOYABLES_TO_SHOW,this._textItems.length)-1?this._currentDeployableIndex++:this._currentDeployableIndex=0,t},i.prototype.animate=function(){if(this._hostData.isIE(8))this.innerAnimate();else{this._attentionGrabberWrapper.css({opacity:0});var t={opacity:1},e=wmjQuery.proxy(this.innerAnimate,this);this._attentionGrabberWrapper.animate(t,{duration:300,complete:e})}},i.prototype.innerAnimate=function(){var t=wmjQuery(".wm-title",this._attentionGrabber),e={opacity:1};this.fixOpacityForIe8(e),t.css(e);var i=this._stopAnimation;t.text(this.htmlDecoder.decodeHtml(this.getDeployableText(),["&",'"',"'",">","<"]));var r=wmjQuery.proxy(this.innerAnimate,this),a=this._timerManager.libSetTimeout;t.animate(e,{duration:700,complete:function(){a(function(){var e={opacity:0};t.animate(e,{duration:700,complete:function(){i||r()}})},2e3)}})},i.prototype.getDirection=function(){return"ltr"},i.prototype.fixOpacityForIe8=function(t){this._hostData.isIE(8)&&(t.opacity=.99)},i}(a.BalloonAttentionGrabber);e.TickerAttentionGrabber=s,r.register("TickerAttentionGrabber").asCtor(s).asProto().dependencies("Lib, CommonUtils, TimerManager, EndUsersManager, AuditSourceManager, HostData, WmAjax, SafeFullUrlProvider, HtmlDecoder")}).call(e,i(1),i(2))},152:function(t,e,i){(function(t){}).call(e,i(2))}});