window.walkMeGermany = true;window._walkmeWebpackJP&&(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[11],{609:function(n,e,t){(function(t,e){(function(){t.register("IntegrationCenterWebhooksInitializer").asCtor(function(u,d,w,p,S,b,k,m,h,f,C){this.start=function(g){return new e(function(e,t){try{var n=p.getSettingsFile(),r=p.getCdnServerName();if(k.isSelfHosted){if(!C.isFeatureEnabled(I))return e();r=n.PlayerApiServer&&n.PlayerApiServer.replace("papi","cdn")}var a=(s=r,localStorage&&localStorage.getItem("wm-integration-center-webhooks-public-path")||s+"/ic/webhooks/1/"),i=(l=p.getSettingsFile(),localStorage&&localStorage.getItem("wm-integration-center-webhooks-api-base-url")||l.PlayerApiServer),o=a+"main.js";u.addScriptWithCallback(o,"onIntegrationCenterWebhooksReadyCb",function(){return{resolve:e,reject:t,wmDependencies:{publicPath:a,apiBaseUrl:i,dataFile:g,wmInternals:k,consts:w,userGuidContainer:b,wmjQuery:S,wmLogger:d,clientStorageManager:m,settingsFile:p,classWalkMeAPI:h,eventSender:f}}},function(){t(new Error("Failed to addScriptWithCallback for: "+o))})}catch(c){t(c)}var l,s})}}).dependencies("CommonUtils, Logger, Consts, SettingsFile, wmjQuery, UserGuidContainer, WmInternals, ClientStorageManager, ClassWalkMeAPI, EventSender, FeaturesManager");var I="IntegrationCenterWebhooksAllowedInSelfHosted";n.exports={init:function(e){return t.get("IntegrationCenterWebhooksInitializer").start(e)["catch"](function(e){t.get("Logger").error(e)})}}}).call(window)}).call(this,t(1),t(28))}}]);
