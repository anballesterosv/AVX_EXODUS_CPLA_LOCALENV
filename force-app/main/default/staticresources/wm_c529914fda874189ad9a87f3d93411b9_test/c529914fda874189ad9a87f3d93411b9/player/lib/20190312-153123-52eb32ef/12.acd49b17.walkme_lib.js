window._walkmeWebpackJP&&(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[12],{610:function(t,e,n){(function(n,e){(function(){n.register("DeepUiInitializer").asCtor(function(o,s,c,d,u,g,p,m,w,f,S,C,F){this.start=function(l){return new e(function(e,n){try{var t=o.getSettingsFile(),r=o.getCdnServerName();if(m.isSelfHosted){if(!u.isFeatureEnabled(I))return e();r=t.PlayerApiServer&&t.PlayerApiServer.replace("papi","cdn")}var i=localStorage&&localStorage.getItem("wm-deepui-snippet-link")||r+"/deepui/0/main.js";s.addScriptWithCallback(i,"onDeepUIReadyCb",function(){return{resolve:e,reject:n,wmDependencies:{datafile:l,settingsFile:o,commonUtils:s,consts:c,wmjQuery:d,elementFinder:g,jQueryElementFinder:p,wmInternals:m,wmLogger:w,clientStorageManager:f,endUsersManager:S,userGuidContainer:C,isInEditor:F}}},function(){n(new Error("Failed to addScriptWithCallback for: "+i))})}catch(a){n(a)}})},function(){}.apply(null,arguments)}).dependencies("SettingsFile, CommonUtils, Consts, wmjQuery, FeaturesManager,ElementFinder, JQueryElementFinder, WmInternals, Logger, ClientStorageManager, EndUsersManager, UserGuidContainer, IsInEditor");var I="DeepUiAllowedInSelfHosted";t.exports={init:function(e){return n.get("DeepUiInitializer").start(e)["catch"](function(e){n.get("Logger").error(e)})}}}).call(window)}).call(this,n(1),n(28))}}]);