/* import and instantiate math expression parser. */
/*var Parser = require('../expr-eval-1.2.2').Parser;*/
!function(t,e){"object"==typeof exports&&"undefined"!=typeof module?module.exports=e():"function"==typeof define&&define.amd?define(e):t.exprEval=e()}(this,function(){"use strict";var t="INUMBER",e="IOP1",s="IOP2",r="IOP3",n="IVAR",i="IFUNCALL",o="IEXPR",a="IMEMBER";function h(t,e){this.type=t,this.value=void 0!==e&&null!==e?e:0}function p(t){return new h(e,t)}function u(t){return new h(s,t)}function c(t){return new h(r,t)}function l(h,p){for(var u,c,v,x,y=[],w=0;w<h.length;w++){var d=h[w],M=d.type;if(M===t)"number"==typeof d.value&&d.value<0?y.push("("+d.value+")"):y.push(f(d.value));else if(M===s)c=y.pop(),u=y.pop(),x=d.value,p?"^"===x?y.push("Math.pow("+u+", "+c+")"):"and"===x?y.push("(!!"+u+" && !!"+c+")"):"or"===x?y.push("(!!"+u+" || !!"+c+")"):"||"===x?y.push("(String("+u+") + String("+c+"))"):"=="===x?y.push("("+u+" === "+c+")"):"!="===x?y.push("("+u+" !== "+c+")"):y.push("("+u+" "+x+" "+c+")"):y.push("("+u+" "+x+" "+c+")");else if(M===r){if(v=y.pop(),c=y.pop(),u=y.pop(),"?"!==(x=d.value))throw new Error("invalid Expression");y.push("("+u+" ? "+c+" : "+v+")")}else if(M===n)y.push(d.value);else if(M===e)u=y.pop(),"-"===(x=d.value)||"+"===x?y.push("("+x+u+")"):p?"not"===x?y.push("(!"+u+")"):"!"===x?y.push("fac("+u+")"):y.push(x+"("+u+")"):"!"===x?y.push("("+u+"!)"):y.push("("+x+" "+u+")");else if(M===i){for(var g=d.value,E=[];g-- >0;)E.unshift(y.pop());x=y.pop(),y.push(x+"("+E.join(", ")+")")}else if(M===a)u=y.pop(),y.push(u+"."+d.value);else{if(M!==o)throw new Error("invalid Expression");y.push("("+l(d.value,p)+")")}}if(y.length>1)throw new Error("invalid Expression (parity)");return String(y[0])}function f(t){return"string"==typeof t?JSON.stringify(t).replace(/\u2028/g,"\\u2028").replace(/\u2029/g,"\\u2029"):t}function v(t,e){for(var s=0;s<t.length;s++)if(t[s]===e)return!0;return!1}function x(t,e,s){for(var r=!!(s=s||{}).withMembers,i=null,h=0;h<t.length;h++){var p=t[h];p.type!==n||v(e,p.value)?p.type===a&&r&&null!==i?i+="."+p.value:p.type===o?x(p.value,e,s):null!==i&&(v(e,i)||e.push(i),i=null):r?null!==i?(v(e,i)||e.push(i),i=p.value):i=p.value:e.push(p.value)}null===i||v(e,i)||e.push(i)}function y(t,e){this.tokens=t,this.parser=e,this.unaryOps=e.unaryOps,this.binaryOps=e.binaryOps,this.ternaryOps=e.ternaryOps,this.functions=e.functions}h.prototype.toString=function(){switch(this.type){case t:case e:case s:case r:case n:return this.value;case i:return"CALL "+this.value;case a:return"."+this.value;default:return"Invalid Instruction"}},y.prototype.simplify=function(i){return i=i||{},new y(function i(p,u,c,l,f){for(var v,x,y,w,d=[],M=[],g=0;g<p.length;g++){var E=p[g],k=E.type;if(k===t)d.push(E);else if(k===n&&f.hasOwnProperty(E.value))E=new h(t,f[E.value]),d.push(E);else if(k===s&&d.length>1)x=d.pop(),v=d.pop(),w=c[E.value],E=new h(t,w(v.value,x.value)),d.push(E);else if(k===r&&d.length>2)y=d.pop(),x=d.pop(),v=d.pop(),"?"===E.value?d.push(v.value?x.value:y.value):(w=l[E.value],E=new h(t,w(v.value,x.value,y.value)),d.push(E));else if(k===e&&d.length>0)v=d.pop(),w=u[E.value],E=new h(t,w(v.value)),d.push(E);else if(k===o){for(;d.length>0;)M.push(d.shift());M.push(new h(o,i(E.value,u,c,l,f)))}else if(k===a&&d.length>0)v=d.pop(),d.push(new h(t,v.value[E.value]));else{for(;d.length>0;)M.push(d.shift());M.push(E)}}for(;d.length>0;)M.push(d.shift());return M}(this.tokens,this.unaryOps,this.binaryOps,this.ternaryOps,i),this.parser)},y.prototype.substitute=function(t,i){return i instanceof y||(i=this.parser.parse(String(i))),new y(function t(i,a,l){for(var f=[],v=0;v<i.length;v++){var x=i[v],y=x.type;if(y===n&&x.value===a)for(var w=0;w<l.tokens.length;w++){var d,M=l.tokens[w];d=M.type===e?p(M.value):M.type===s?u(M.value):M.type===r?c(M.value):new h(M.type,M.value),f.push(d)}else y===o?f.push(new h(o,t(x.value,a,l))):f.push(x)}return f}(this.tokens,t,i),this.parser)},y.prototype.evaluate=function(h){return h=h||{},function h(p,u,c){for(var l,f,v,x,y=[],w=0;w<p.length;w++){var d=p[w],M=d.type;if(M===t)y.push(d.value);else if(M===s)f=y.pop(),l=y.pop(),"and"===d.value?y.push(!!l&&!!h(f,u,c)):"or"===d.value?y.push(!!l||!!h(f,u,c)):(x=u.binaryOps[d.value],y.push(x(l,f)));else if(M===r)v=y.pop(),f=y.pop(),l=y.pop(),"?"===d.value?y.push(h(l?f:v,u,c)):(x=u.ternaryOps[d.value],y.push(x(l,f,v)));else if(M===n)if(d.value in u.functions)y.push(u.functions[d.value]);else{var g=c[d.value];if(void 0===g)throw new Error("undefined variable: "+d.value);y.push(g)}else if(M===e)l=y.pop(),x=u.unaryOps[d.value],y.push(x(l));else if(M===i){for(var E=d.value,k=[];E-- >0;)k.unshift(y.pop());if(!(x=y.pop()).apply||!x.call)throw new Error(x+" is not a function");y.push(x.apply(void 0,k))}else if(M===o)y.push(d.value);else{if(M!==a)throw new Error("invalid Expression");l=y.pop(),y.push(l[d.value])}}if(y.length>1)throw new Error("invalid Expression (parity)");return y[0]}(this.tokens,this,h)},y.prototype.toString=function(){return l(this.tokens,!1)},y.prototype.symbols=function(t){t=t||{};var e=[];return x(this.tokens,e,t),e},y.prototype.variables=function(t){t=t||{};var e=[];x(this.tokens,e,t);var s=this.functions;return e.filter(function(t){return!(t in s)})},y.prototype.toJSFunction=function(t,e){var s=this,r=new Function(t,"with(this.functions) with (this.ternaryOps) with (this.binaryOps) with (this.unaryOps) { return "+l(this.simplify(e).tokens,!0)+"; }");return function(){return r.apply(s,arguments)}};var w="TOP";function d(t,e,s){this.type=t,this.value=e,this.index=s}function M(t,e){this.pos=0,this.current=null,this.unaryOps=t.unaryOps,this.binaryOps=t.binaryOps,this.ternaryOps=t.ternaryOps,this.consts=t.consts,this.expression=e,this.savedPosition=0,this.savedCurrent=null,this.options=t.options}d.prototype.toString=function(){return this.type+": "+this.value},M.prototype.newToken=function(t,e,s){return new d(t,e,null!=s?s:this.pos)},M.prototype.save=function(){this.savedPosition=this.pos,this.savedCurrent=this.current},M.prototype.restore=function(){this.pos=this.savedPosition,this.current=this.savedCurrent},M.prototype.next=function(){return this.pos>=this.expression.length?this.newToken("TEOF","EOF"):this.isWhitespace()||this.isComment()?this.next():this.isRadixInteger()||this.isNumber()||this.isOperator()||this.isString()||this.isParen()||this.isComma()||this.isNamedOp()||this.isConst()||this.isName()?this.current:void this.parseError('Unknown character "'+this.expression.charAt(this.pos)+'"')},M.prototype.isString=function(){var t=!1,e=this.pos,s=this.expression.charAt(e);if("'"===s||'"'===s)for(var r=this.expression.indexOf(s,e+1);r>=0&&this.pos<this.expression.length;){if(this.pos=r+1,"\\"!==this.expression.charAt(r-1)){var n=this.expression.substring(e+1,r);this.current=this.newToken("TSTRING",this.unescape(n),e),t=!0;break}r=this.expression.indexOf(s,r+1)}return t},M.prototype.isParen=function(){var t=this.expression.charAt(this.pos);return("("===t||")"===t)&&(this.current=this.newToken("TPAREN",t),this.pos++,!0)},M.prototype.isComma=function(){return","===this.expression.charAt(this.pos)&&(this.current=this.newToken("TCOMMA",","),this.pos++,!0)},M.prototype.isConst=function(){for(var t=this.pos,e=t;e<this.expression.length;e++){var s=this.expression.charAt(e);if(s.toUpperCase()===s.toLowerCase()&&(e===this.pos||"_"!==s&&"."!==s&&(s<"0"||s>"9")))break}if(e>t){var r=this.expression.substring(t,e);if(r in this.consts)return this.current=this.newToken("TNUMBER",this.consts[r]),this.pos+=r.length,!0}return!1},M.prototype.isNamedOp=function(){for(var t=this.pos,e=t;e<this.expression.length;e++){var s=this.expression.charAt(e);if(s.toUpperCase()===s.toLowerCase()&&(e===this.pos||"_"!==s&&(s<"0"||s>"9")))break}if(e>t){var r=this.expression.substring(t,e);if(this.isOperatorEnabled(r)&&(r in this.binaryOps||r in this.unaryOps||r in this.ternaryOps))return this.current=this.newToken(w,r),this.pos+=r.length,!0}return!1},M.prototype.isName=function(){for(var t=this.pos,e=t,s=!1;e<this.expression.length;e++){var r=this.expression.charAt(e);if(r.toUpperCase()===r.toLowerCase()){if(e===this.pos&&("$"===r||"_"===r)){"_"===r&&(s=!0);continue}if(e===this.pos||!s||"_"!==r&&(r<"0"||r>"9"))break}else s=!0}if(s){var n=this.expression.substring(t,e);return this.current=this.newToken("TNAME",n),this.pos+=n.length,!0}return!1},M.prototype.isWhitespace=function(){for(var t=!1,e=this.expression.charAt(this.pos);!(" "!==e&&"\t"!==e&&"\n"!==e&&"\r"!==e||(t=!0,this.pos++,this.pos>=this.expression.length));)e=this.expression.charAt(this.pos);return t};var g=/^[0-9a-f]{4}$/i;M.prototype.unescape=function(t){var e=t.indexOf("\\");if(e<0)return t;for(var s=t.substring(0,e);e>=0;){var r=t.charAt(++e);switch(r){case"'":s+="'";break;case'"':s+='"';break;case"\\":s+="\\";break;case"/":s+="/";break;case"b":s+="\b";break;case"f":s+="\f";break;case"n":s+="\n";break;case"r":s+="\r";break;case"t":s+="\t";break;case"u":var n=t.substring(e+1,e+5);g.test(n)||this.parseError("Illegal escape sequence: \\u"+n),s+=String.fromCharCode(parseInt(n,16)),e+=4;break;default:throw this.parseError('Illegal escape sequence: "\\'+r+'"')}++e;var i=t.indexOf("\\",e);s+=t.substring(e,i<0?t.length:i),e=i}return s},M.prototype.isComment=function(){return"/"===this.expression.charAt(this.pos)&&"*"===this.expression.charAt(this.pos+1)&&(this.pos=this.expression.indexOf("*/",this.pos)+2,1===this.pos&&(this.pos=this.expression.length),!0)},M.prototype.isRadixInteger=function(){var t,e,s=this.pos;if(s>=this.expression.length-2||"0"!==this.expression.charAt(s))return!1;if(++s,"x"===this.expression.charAt(s))t=16,e=/^[0-9a-f]$/i,++s;else{if("b"!==this.expression.charAt(s))return!1;t=2,e=/^[01]$/i,++s}for(var r=!1,n=s;s<this.expression.length;){var i=this.expression.charAt(s);if(!e.test(i))break;s++,r=!0}return r&&(this.current=this.newToken("TNUMBER",parseInt(this.expression.substring(n,s),t)),this.pos=s),r},M.prototype.isNumber=function(){for(var t,e=!1,s=this.pos,r=s,n=s,i=!1,o=!1;s<this.expression.length&&((t=this.expression.charAt(s))>="0"&&t<="9"||!i&&"."===t);)"."===t?i=!0:o=!0,s++,e=o;if(e&&(n=s),"e"===t||"E"===t){s++;for(var a=!0,h=!1;s<this.expression.length;){if(t=this.expression.charAt(s),!a||"+"!==t&&"-"!==t){if(!(t>="0"&&t<="9"))break;h=!0,a=!1}else a=!1;s++}h||(s=n)}return e?(this.current=this.newToken("TNUMBER",parseFloat(this.expression.substring(r,s))),this.pos=s):this.pos=n,e},M.prototype.isOperator=function(){var t=this.pos,e=this.expression.charAt(this.pos);if("+"===e||"-"===e||"*"===e||"/"===e||"%"===e||"^"===e||"?"===e||":"===e||"."===e)this.current=this.newToken(w,e);else if("∙"===e||"•"===e)this.current=this.newToken(w,"*");else if(">"===e)"="===this.expression.charAt(this.pos+1)?(this.current=this.newToken(w,">="),this.pos++):this.current=this.newToken(w,">");else if("<"===e)"="===this.expression.charAt(this.pos+1)?(this.current=this.newToken(w,"<="),this.pos++):this.current=this.newToken(w,"<");else if("|"===e){if("|"!==this.expression.charAt(this.pos+1))return!1;this.current=this.newToken(w,"||"),this.pos++}else if("="===e){if("="!==this.expression.charAt(this.pos+1))return!1;this.current=this.newToken(w,"=="),this.pos++}else{if("!"!==e)return!1;"="===this.expression.charAt(this.pos+1)?(this.current=this.newToken(w,"!="),this.pos++):this.current=this.newToken(w,e)}return this.pos++,!!this.isOperatorEnabled(this.current.value)||(this.pos=t,!1)};var E={"+":"add","-":"subtract","*":"multiply","/":"divide","%":"remainder","^":"power","!":"factorial","<":"comparison",">":"comparison","<=":"comparison",">=":"comparison","==":"comparison","!=":"comparison","||":"concatenate",and:"logical",or:"logical",not:"logical","?":"conditional",":":"conditional"};function k(t,e,s){this.parser=t,this.tokens=e,this.current=null,this.nextToken=null,this.next(),this.savedCurrent=null,this.savedNextToken=null,this.allowMemberAccess=!1!==s.allowMemberAccess}M.prototype.isOperatorEnabled=function(t){var e=function(t){return E.hasOwnProperty(t)?E[t]:t}(t),s=this.options.operators||{};return"in"===e?!!s.in:!(e in s&&!s[e])},M.prototype.getCoordinates=function(){var t,e=0,s=-1;do{e++,t=this.pos-s,s=this.expression.indexOf("\n",s+1)}while(s>=0&&s<this.pos);return{line:e,column:t}},M.prototype.parseError=function(t){var e=this.getCoordinates();throw new Error("parse error ["+e.line+":"+e.column+"]: "+t)},k.prototype.next=function(){return this.current=this.nextToken,this.nextToken=this.tokens.next()},k.prototype.tokenMatches=function(t,e){return void 0===e||(Array.isArray(e)?v(e,t.value):"function"==typeof e?e(t):t.value===e)},k.prototype.save=function(){this.savedCurrent=this.current,this.savedNextToken=this.nextToken,this.tokens.save()},k.prototype.restore=function(){this.tokens.restore(),this.current=this.savedCurrent,this.nextToken=this.savedNextToken},k.prototype.accept=function(t,e){return!(this.nextToken.type!==t||!this.tokenMatches(this.nextToken,e))&&(this.next(),!0)},k.prototype.expect=function(t,e){if(!this.accept(t,e)){var s=this.tokens.getCoordinates();throw new Error("parse error ["+s.line+":"+s.column+"]: Expected "+(e||t))}},k.prototype.parseAtom=function(e){if(this.accept("TNAME"))e.push(new h(n,this.current.value));else if(this.accept("TNUMBER"))e.push(new h(t,this.current.value));else if(this.accept("TSTRING"))e.push(new h(t,this.current.value));else{if(!this.accept("TPAREN","("))throw new Error("unexpected "+this.nextToken);this.parseExpression(e),this.expect("TPAREN",")")}},k.prototype.parseExpression=function(t){this.parseConditionalExpression(t)},k.prototype.parseConditionalExpression=function(t){for(this.parseOrExpression(t);this.accept(w,"?");){var e=[],s=[];this.parseConditionalExpression(e),this.expect(w,":"),this.parseConditionalExpression(s),t.push(new h(o,e)),t.push(new h(o,s)),t.push(c("?"))}},k.prototype.parseOrExpression=function(t){for(this.parseAndExpression(t);this.accept(w,"or");){var e=[];this.parseAndExpression(e),t.push(new h(o,e)),t.push(u("or"))}},k.prototype.parseAndExpression=function(t){for(this.parseComparison(t);this.accept(w,"and");){var e=[];this.parseComparison(e),t.push(new h(o,e)),t.push(u("and"))}};var b=["==","!=","<","<=",">=",">","in"];k.prototype.parseComparison=function(t){for(this.parseAddSub(t);this.accept(w,b);){var e=this.current;this.parseAddSub(t),t.push(u(e.value))}};var m=["+","-","||"];k.prototype.parseAddSub=function(t){for(this.parseTerm(t);this.accept(w,m);){var e=this.current;this.parseTerm(t),t.push(u(e.value))}};var T=["*","/","%"];function A(t,e){return Number(t)+Number(e)}function O(t,e){return t-e}function N(t,e){return t*e}function C(t,e){return t/e}function P(t,e){return t%e}function I(t,e){return""+t+e}function S(t,e){return t===e}function R(t,e){return t!==e}function F(t,e){return t>e}function L(t,e){return t<e}function U(t,e){return t>=e}function q(t,e){return t<=e}function B(t,e){return Boolean(t&&e)}function _(t,e){return Boolean(t||e)}function $(t,e){return v(e,t)}function G(t){return(Math.exp(t)-Math.exp(-t))/2}function j(t){return(Math.exp(t)+Math.exp(-t))/2}function J(t){return t===1/0?1:t===-1/0?-1:(Math.exp(t)-Math.exp(-t))/(Math.exp(t)+Math.exp(-t))}function W(t){return t===-1/0?t:Math.log(t+Math.sqrt(t*t+1))}function V(t){return Math.log(t+Math.sqrt(t*t-1))}function X(t){return Math.log((1+t)/(1-t))/2}function z(t){return Math.log(t)*Math.LOG10E}function D(t){return-t}function H(t){return!t}function K(t){return t<0?Math.ceil(t):Math.floor(t)}function Q(t){return Math.random()*(t||1)}function Y(t){return et(t+1)}k.prototype.parseTerm=function(t){for(this.parseFactor(t);this.accept(w,T);){var e=this.current;this.parseFactor(t),t.push(u(e.value))}},k.prototype.parseFactor=function(t){var e=this.tokens.unaryOps;if(this.save(),this.accept(w,function(t){return t.value in e}))if("-"!==this.current.value&&"+"!==this.current.value&&"TPAREN"===this.nextToken.type&&"("===this.nextToken.value)this.restore(),this.parseExponential(t);else{var s=this.current;this.parseFactor(t),t.push(p(s.value))}else this.parseExponential(t)},k.prototype.parseExponential=function(t){for(this.parsePostfixExpression(t);this.accept(w,"^");)this.parseFactor(t),t.push(u("^"))},k.prototype.parsePostfixExpression=function(t){for(this.parseFunctionCall(t);this.accept(w,"!");)t.push(p("!"))},k.prototype.parseFunctionCall=function(t){var e=this.tokens.unaryOps;if(this.accept(w,function(t){return t.value in e})){var s=this.current;this.parseAtom(t),t.push(p(s.value))}else for(this.parseMemberExpression(t);this.accept("TPAREN","(");)if(this.accept("TPAREN",")"))t.push(new h(i,0));else{var r=this.parseArgumentList(t);t.push(new h(i,r))}},k.prototype.parseArgumentList=function(t){for(var e=0;!this.accept("TPAREN",")");)for(this.parseExpression(t),++e;this.accept("TCOMMA");)this.parseExpression(t),++e;return e},k.prototype.parseMemberExpression=function(t){for(this.parseAtom(t);this.accept(w,".");){if(!this.allowMemberAccess)throw new Error('unexpected ".", member access is not permitted');this.expect("TNAME"),t.push(new h(a,this.current.value))}};var Z=4.7421875,tt=[.9999999999999971,57.15623566586292,-59.59796035547549,14.136097974741746,-.4919138160976202,3399464998481189e-20,4652362892704858e-20,-9837447530487956e-20,.0001580887032249125,-.00021026444172410488,.00021743961811521265,-.0001643181065367639,8441822398385275e-20,-26190838401581408e-21,36899182659531625e-22];function et(t){var e,s;if(function(t){return isFinite(t)&&t===Math.round(t)}(t)){if(t<=0)return isFinite(t)?1/0:NaN;if(t>171)return 1/0;for(var r=t-2,n=t-1;r>1;)n*=r,r--;return 0===n&&(n=1),n}if(t<.5)return Math.PI/(Math.sin(Math.PI*t)*et(1-t));if(t>=171.35)return 1/0;if(t>85){var i=t*t,o=i*t,a=o*t,h=a*t;return Math.sqrt(2*Math.PI/t)*Math.pow(t/Math.E,t)*(1+1/(12*t)+1/(288*i)-139/(51840*o)-571/(2488320*a)+163879/(209018880*h)+5246819/(75246796800*h*t))}--t,s=tt[0];for(var p=1;p<tt.length;++p)s+=tt[p]/(t+p);return e=t+Z+.5,Math.sqrt(2*Math.PI)*Math.pow(e,t+.5)*Math.exp(-e)*s}function st(t){return String(t).length}function rt(){for(var t=0,e=0,s=0;s<arguments.length;s++){var r,n=Math.abs(arguments[s]);e<n?(t=t*(r=e/n)*r+1,e=n):t+=n>0?(r=n/e)*r:n}return e===1/0?1/0:e*Math.sqrt(t)}function nt(t,e,s){return t?e:s}function it(t,e){return void 0===e||0==+e?Math.round(t):(t=+t,e=-+e,isNaN(t)||"number"!=typeof e||e%1!=0?NaN:(t=t.toString().split("e"),+((t=(t=Math.round(+(t[0]+"e"+(t[1]?+t[1]-e:-e)))).toString().split("e"))[0]+"e"+(t[1]?+t[1]+e:e))))}function ot(t){this.options=t||{},this.unaryOps={sin:Math.sin,cos:Math.cos,tan:Math.tan,asin:Math.asin,acos:Math.acos,atan:Math.atan,sinh:Math.sinh||G,cosh:Math.cosh||j,tanh:Math.tanh||J,asinh:Math.asinh||W,acosh:Math.acosh||V,atanh:Math.atanh||X,sqrt:Math.sqrt,log:Math.log,ln:Math.log,lg:Math.log10||z,log10:Math.log10||z,abs:Math.abs,ceil:Math.ceil,floor:Math.floor,round:Math.round,trunc:Math.trunc||K,"-":D,"+":Number,exp:Math.exp,not:H,length:st,"!":Y},this.binaryOps={"+":A,"-":O,"*":N,"/":C,"%":P,"^":Math.pow,"||":I,"==":S,"!=":R,">":F,"<":L,">=":U,"<=":q,and:B,or:_,in:$},this.ternaryOps={"?":nt},this.functions={random:Q,fac:Y,min:Math.min,max:Math.max,hypot:Math.hypot||rt,pyt:Math.hypot||rt,pow:Math.pow,atan2:Math.atan2,if:nt,gamma:et,roundTo:it},this.consts={E:Math.E,PI:Math.PI,true:!0,false:!1}}ot.prototype.parse=function(t){var e=[],s=new k(this,new M(this,t),{allowMemberAccess:this.options.allowMemberAccess});return s.parseExpression(e),s.expect("TEOF","EOF"),new y(e,this)},ot.prototype.evaluate=function(t,e){return this.parse(t).evaluate(e)};var at=new ot;return ot.parse=function(t){return at.parse(t)},ot.evaluate=function(t,e){return at.parse(t).evaluate(e)},{Parser:ot,Expression:y}});

var parser = new exprEval.Parser();

/*
function prepareArray(mins, maxs) {
  let out = [];
  for (let i = 0; i < mins.length; i++) {
    out.push([mins[i], maxs[i]]);
  }
  return out;
}


function combine(x, y) {
  let out = [];
  for (let i = 0; i < x.length; i++) {
    for (let j = 0; j < x.length; j++) {
      out.push([x[i], y[j]]);
    }
  }
  return out;
}

function wrapArrays(x, len) {
  let out = [];
  for (let h = len - 2; h >= 0; h--) {
    if (h === len - 2) {
      out.push(combine(x[h], x[h + 1]));
    } else {
      out.push(combine(x[h], out));
    }
  }
  return out;
}
*/


function prepareArray(x, y) {
  let out = [];
  for (let i = 0; i < x.length; i++) {
    out.push([x[i], y[i]]);
  }
  return out;
}

function combiner(x, y) {
    let out = new Array(x.length);
    let n = 0;
    for (let i = 0; i < x.length; i++) {
        for (let j = 0; j < y.length; j++) {
            out[n] = [x[i], y[j]];
            n = n + 1;
        }
    }
    return out;
}

function wrapArrays(x, len) {
    let out = [];
    for (let h = len - 2; h >= 0; h--) {
        if (h === len - 2) {
            out = combiner(x[h], x[h + 1]);
        } else {
            out = combiner(x[h], out);
        }
        for (let k = 0; k < out.length; k++) {
            out[k] = out[k].flat();
        }
    }
    return out;
}

function evalDomain(arr, arith) {
  var out = [];
  for (let i = 0; i < arr.length; i++) {
    values = arr[i];
    out.push(evalMath(arith, values));
  }
  return [Math.min(...out), Math.max(...out)];
}

/*
function evalMath(a, values) {
    return Function('values', 'with(Math) return ' + a)(values);
} */

// this function can further be optimized by parsing the expression once for repeated calls with different values
// 
function evalMath(rawExpression, values) {
    var expression = parser.parse(rawExpression);
    var result = expression.evaluate({ values });
    return result;
}


// helpers from https://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
function componentToHex(c) {
  var hex = c.toString(16);
  return hex.length == 1 ? '0' + hex : hex;
}

function rgbToHex(r, g, b) {
  return '#' +
    componentToHex(r) +
    componentToHex(g) +
    componentToHex(b);
}

// https://gist.github.com/fpillet/993002
function scaleValue(value, from, to) {
  if (isNaN(value)) return NaN;
	var scale = (to[1] - to[0]) / (from[1] - from[0]);
	var capped = Math.min(from[1], Math.max(from[0], value)) - from[0];
	return ~~(capped * scale + to[0]);
}

// https://stackoverflow.com/questions/35325767/map-an-array-of-arrays
function deepMap(input,callback) {
  return input.map(entry=>entry.map?deepMap(entry,callback):callback(entry));
}

function rescale(value, to_min, to_max, from_min, from_max) {
  if (value === undefined) {
    value = from_min;
  }
  return (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min;
}

function naExclude(n) { return !isNaN(n); }


const combinations = ([head, ...tail]) => tail.length > 0 ? [...tail.map(tailValue => [head, tailValue]), ...combinations(tail)] : [];

