window.walkMeGermany = true;(window._walkmeWebpackJP=window._walkmeWebpackJP||[]).push([[13],{611:function(e,n,r){(function(){var n=r(612),t={init:function(){var e=n.get("NonWebComponentDrawableCreator");t.drawElement=e.drawElement},services:["NonWebComponentDrawableCreator"],types:[]};r(613),r(67).registerApi(t,n),e.exports=t}).call(window)},612:function(e,n,t){(function(){e.exports=t(67).create()}).call(window)},613:function(e,n,t){(function(){t(612).register("NonWebComponentDrawableCreator").asCtor(function(e,l,d,c,w){this.drawElement=function(e){var n=document.createElement("div"),t=w.getRandomId();n.id=t,n.className+=" walkme-to-remove";for(var r=l.getElementData(e),a=r.nodes,o=0;o<a.length;o++)n.appendChild(a[o]);var i=function(e,n,t){var r={position:"absolute","z-index":"2147483647"},a=e.outerStyle;for(var o in a)r[o]=a[o];var i=e.style;for(var o in i)r[o]=i[o];var l=d.createStrongStyleString(n,r);return l+=t.innerStyle}(e,t,r);return c.addStyle(i,t),n}}).dependencies("CommonUtils, GeneralDrawableDrawer, StyleCreator, StyleAdder, DomIdGenerator")}).call(window)}}]);
