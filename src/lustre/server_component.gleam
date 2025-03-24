//// > **Note**: server components are currently only supported on the **Erlang**
//// > target. If it's important to you that they work on the JavaScript target,
//// > [open an issue](https://github.com/lustre-labs/lustre/issues/new) and tell
//// > us why it's important to you!
////
//// Server components are an advanced feature that allows you to run components
//// or full Lustre applications on the server. Updates are broadcast to a small
//// (<20kb!) client runtime that patches the DOM and events are sent back to the
//// server component in real-time.
////
//// ```text
//// -- SERVER -----------------------------------------------------------------
////
////                  Msg                            Element(Msg)
//// +--------+        v        +----------------+        v        +------+
//// |        | <-------------- |                | <-------------- |      |
//// | update |                 | Lustre runtime |                 | view |
//// |        | --------------> |                | --------------> |      |
//// +--------+        ^        +----------------+        ^        +------+
////         #(model, Effect(msg))  |        ^          Model
////                                |        |
////                                |        |
////                    DOM patches |        | DOM events
////                                |        |
////                                v        |
////                        +-----------------------+
////                        |                       |
////                        | Your WebSocket server |
////                        |                       |
////                        +-----------------------+
////                                |        ^
////                                |        |
////                    DOM patches |        | DOM events
////                                |        |
////                                v        |
//// -- BROWSER ----------------------------------------------------------------
////                                |        ^
////                                |        |
////                    DOM patches |        | DOM events
////                                |        |
////                                v        |
////                            +----------------+
////                            |                |
////                            | Client runtime |
////                            |                |
////                            +----------------+
//// ```
////
//// **Note**: Lustre's server component runtime is separate from your application's
//// WebSocket server. You're free to bring your own stack, connect multiple
//// clients to the same Lustre instance, or keep the application alive even when
//// no clients are connected.
////
//// Lustre server components run next to the rest of your backend code, your
//// services, your database, etc. Real-time applications like chat services, games,
//// or components that can benefit from direct access to your backend services
//// like an admin dashboard or data table are excellent candidates for server
//// components.
////
//// ## Examples
////
//// Server components are a new feature in Lustre and we're still working on the
//// best ways to use them and show them off. For now, you can find a simple
//// undocumented example in the `examples/` directory:
////
//// - [`99-server-components`](https://github.com/lustre-labs/lustre/tree/main/examples/99-server-components)
////
//// ## Getting help
////
//// If you're having trouble with Lustre or not sure what the right way to do
//// something is, the best place to get help is the [Gleam Discord server](https://discord.gg/Fm8Pwmy).
//// You could also open an issue on the [Lustre GitHub repository](https://github.com/lustre-labs/lustre/issues).
////

// IMPORTS ---------------------------------------------------------------------

import gleam/dynamic/decode.{type Decoder}
import gleam/erlang/process.{type Selector, type Subject}
import gleam/json.{type Json}
import lustre.{type Error, type Runtime, type RuntimeMessage}
import lustre/attribute.{type Attribute, attribute}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/runtime/server/runtime
import lustre/runtime/transport
import lustre/vdom/attribute.{Event} as _

// TYPES -----------------------------------------------------------------------

/// A type representing the messages sent to the server component _client_
/// runtime. This instruct the client runtime to do things like update the DOM
/// or emit an event from the element.
///
pub type ClientMessage(msg) =
  transport.ClientMessage(msg)

pub type TransportMethod {
  WebSocket
  ServerSentEvents
  Polling
}

// ELEMENTS --------------------------------------------------------------------

/// Render the server component custom element. This element acts as the thin
/// client runtime for a server component running remotely.
///
/// **Note**: the server component runtime bundle must be included and sent to
/// the client for this to work correctly. You can do this by including the
/// JavaScript bundle found in Lustre's `priv/static` directory or by inlining
/// the script source directly with the [`script`](#script) element below.
///
pub fn element(
  attrs: List(Attribute(msg)),
  children: List(Element(msg)),
) -> Element(msg) {
  element.element("lustre-server-component", attrs, children)
}

/// Inline the server component client runtime as a `<script>` tag. Where possible
/// you should prefer serving the pre-built client runtime from Lustre's `priv/static`
/// directory, but this inline script can be useful for development or scenarios
/// where you don't control the HTML document.
///
pub fn script() -> Element(msg) {
  html.script(
    [attribute.type_("module")],
    // <<INJECT RUNTIME>>
    "var Jn=new DataView(new ArrayBuffer(8));var kt=5,H=Math.pow(2,kt),Hn=H-1,Vn=H/2,Yn=H/4;var Kn=Symbol();var ge=[\" \",\"	\",`\\n`,\"\\v\",\"\\f\",\"\\r\",\"\\x85\",\"\\u2028\",\"\\u2029\"].join(\"\"),lr=new RegExp(`^[${ge}]*`),ar=new RegExp(`[${ge}]*$`);var Se=0;var Ae=1;var Be=2;var Ce=0;var Ne=1;var Te=2;var Ie=3;var Fe=0;var Re=1;var Ge=2;var ee=3;var We=4;var te=5;var ne=6;var re=7;var M=class{#r=null;#e=()=>{};#t=!1;constructor(e,t,{useServerEvents:n=!1}={}){this.#r=e,this.#e=t,this.#t=n}mount(e){this.#r.appendChild(this.#p(e))}#n=[];push(e,t=0){t&&(m(e.changes,n=>{switch(n.kind){case ne:n.before+=t;break;case ee:n.before+=t;break;case re:n.from+=t;break;case te:n.from+=t;break}}),m(e.children,n=>{n.index+=t})),this.#n.push({node:this.#r,patch:e}),this.#s()}#s(){for(;this.#n.length;){let{node:e,patch:t}=this.#n.pop();m(t.changes,n=>{switch(n.kind){case ne:this.#i(e,n.children,n.before);break;case ee:this.#u(e,n.key,n.before,n.count);break;case We:this.#f(e,n.key,n.count);break;case re:this.#l(e,n.from,n.count);break;case te:this.#c(e,n.from,n.count,n.with);break;case Fe:this.#d(e,n.content);break;case Re:this.#a(e,n.inner_html);break;case Ge:this.#h(e,n.added,n.removed);break}}),t.removed&&this.#l(e,e.childNodes.length-t.removed,t.removed),m(t.children,n=>{this.#n.push({node:e.childNodes[n.index],patch:n})})}}#i(e,t,n){let r=document.createDocumentFragment();m(t,i=>{let d=this.#p(i);ie(e,d),r.appendChild(d)}),e.insertBefore(r,e.childNodes[n]??null)}#u(e,t,n,r){let i=e[a].keyedChildren.get(t).deref();if(r>1){let d=document.createDocumentFragment();for(let f=0;f<r&&i!==null;++f){let y=i.nextSibling;d.append(i),i=y}i=d}e.insertBefore(i,e.childNodes[n]??null)}#f(e,t,n){this.#o(e,e[a].keyedChildren.get(t).deref(),n)}#l(e,t,n){this.#o(e,e.childNodes[t],n)}#o(e,t,n){for(;n-- >0&&t!==null;){let r=t.nextSibling,i=t[a].key;i&&e[a].keyedChildren.delete(i),e.removeChild(t),t=r}}#c(e,t,n,r){this.#l(e,t,n);let i=this.#p(r);ie(e,i),e.insertBefore(i,e.childNodes[t]??null)}#d(e,t){e.data=t}#a(e,t){e.innerHTML=t}#h(e,t,n){m(n,r=>{let i=r.name;e[a].handlers.has(i)?(e.removeEventListener(i,He),e[a].handlers.delete(i)):(e.removeAttribute(i),Ve[i]?.removed?.(e,i))}),m(t,r=>{this.#_(e,r)})}#p(e){switch(e.kind){case Ne:{let t=e.namespace?document.createElementNS(e.namespace,e.tag):document.createElement(e.tag);return I(t,e.key),m(e.attributes,n=>{this.#_(t,n)}),this.#i(t,e.children,0),t}case Te:{let t=document.createTextNode(e.content);return I(t,e.key),t}case Ce:{let t=document.createDocumentFragment(),n=document.createTextNode(\"\");return I(n,e.key),t.appendChild(n),m(e.children,r=>{t.appendChild(this.#p(r))}),t}case Ie:{let t=e.namespace?document.createElementNS(e.namespace,e.tag):document.createElement(e.tag);return I(t,e.key),m(e.attributes,n=>{this.#_(t,n)}),this.#a(t,e.inner_html),t}}}#_(e,t){switch(t.kind){case Se:{let n=t.name,r=t.value;r!==e.getAttribute(n)&&e.setAttribute(n,r),Ve[n]?.added?.(e,r);break}case Ae:e[t.name]=t.value;break;case Be:{e[a].handlers.has(t.name)||e.addEventListener(t.name,He,{passive:!t.prevent_default});let n=t.prevent_default,r=t.stop_propagation,i=t.immediate,d=Array.isArray(t.include)?t.include:[];e[a].handlers.set(t.name,f=>{n&&f.preventDefault(),r&&f.stopPropagation();let y=[],b=f.currentTarget;for(;b!==this.#r;){let ce=b[a].key;if(ce)y.push(ce);else{let it=[].indexOf.call(b.parentNode.childNodes,b);y.push(it.toString())}b=b.parentNode}y.reverse();let rt=this.#t?Wt(f,d):f;this.#e(rt,y,f.type,i)});break}}}};function m(s,e){if(Array.isArray(s))for(let t=0;t<s.length;t++)e(s[t]);else for(s;s.tail;s=s.tail)e(s.head)}var a=Symbol(\"metadata\");function I(s,e=\"\"){switch(s.nodeType){case Node.ELEMENT_NODE:case Node.DOCUMENT_FRAGMENT_NODE:s[a]={key:e,keyedChildren:new Map,handlers:new Map};break;case Node.TEXT_NODE:s[a]={key:e};break}}function ie(s,e){if(e.nodeType===Node.DOCUMENT_FRAGMENT_NODE){for(e=e.firstChild;e;e=e.nextSibling)ie(s,e);return}let t=e[a].key;t&&s[a].keyedChildren.set(t,new WeakRef(e))}function He(s){s.currentTarget[a].handlers.get(s.type)(s)}function Wt(s,e=[]){let t={};(s.type===\"input\"||s.type===\"change\")&&e.push(\"target.value\");for(let n of e){let r=n.split(\".\");for(let i=0,d=s,f=t;i<r.length;i++){if(i===r.length-1){f[r[i]]=d[r[i]];break}f=f[r[i]]??={},d=d[r[i]]}}return t}var Ve={checked:Ye(\"checked\"),selected:Ye(\"selected\"),value:Jt(\"value\"),autofocus:{added(s){s.focus?.()}},autoplay:{added(s){try{s.play?.()}catch(e){console.error(e)}}}};function Ye(s){return{added(e,t){e[s]=!0},removed(e){e[s]=!1}}}function Jt(s){return{added(e,t){e[s]=t}}}var Ke=new WeakMap;async function Xe(s){let e=[];for(let n of document.querySelectorAll(\"link[rel=stylesheet], style\"))n.sheet||e.push(new Promise((r,i)=>{n.addEventListener(\"load\",r),n.addEventListener(\"error\",i)}));if(await Promise.allSettled(e),!s.host.isConnected)return[];s.adoptedStyleSheets=s.host.getRootNode().adoptedStyleSheets;let t=[];for(let n of document.styleSheets)try{s.adoptedStyleSheets.push(n)}catch{try{let r=Ke.get(n);if(!r){r=new CSSStyleSheet;for(let i of n.cssRules)r.insertRule(i.cssText,r.cssRules.length);Ke.set(n,r)}s.adoptedStyleSheets.push(r)}catch{let r=n.ownerNode.cloneNode();s.prepend(r),t.push(r)}}return t}var Qe=0;var Ze=1;var et=2;var se=0;var tt=1;var nt=2;var ue=3;var oe=class extends HTMLElement{static get observedAttributes(){return[\"route\",\"method\"]}#r;#e=\"ws\";#t=null;#n=null;#s=!0;#i=[];#u;#f=new Set;#l=new Set;#o=!1;#c=[];#d=new MutationObserver(e=>{let t=[];for(let n of e){if(n.type!==\"attributes\")continue;let r=n.attributeName;(this.#o||this.#f.includes(r))&&t.push([r,this.getAttribute(r)])}t.length&&this.#o?this.#n?.send({kind:batch,messages:t.map(([n,r])=>({kind:se,name:n,value:r}))}):this.#c.push(...t)});constructor(){super(),this.internals=this.attachInternals(),this.#d.observe(this,{attributes:!0})}connectedCallback(){this.#e=this.getAttribute(\"method\")||\"ws\",this.hasAttribute(\"route\")&&(this.#t=new URL(this.getAttribute(\"route\"),window.location.href),this.#a())}attributeChangedCallback(e,t,n){switch(e){case t!==n:{this.#t=new URL(n,window.location.href),this.#a();return}case\"method\":{let r=n.toLowerCase();if(r==this.#e)return;[\"ws\",\"sse\",\"polling\"].includes(r)&&(this.#e=r,this.#e==\"ws\"&&(this.#t.protocol==\"https:\"&&(this.#t.protocol=\"wss:\"),this.#t.protocol==\"http:\"&&(this.#t.protocol=\"ws:\")),this.#a());return}}}async messageReceivedCallback(e){switch(e.kind){case Qe:{this.#r=this.attachShadow({mode:e.open_shadow_root?\"open\":\"closed\"}),this.#u=new M(this.#r,(n,r,i)=>{this.#n?.send({kind:tt,path:r,name:i,event:n})},{useServerEvents:!0}),this.#f=new Set(e.observed_attributes);let t=this.#c.filter(([n])=>this.#f.has(n));t.length&&this.#n.send({kind:ue,messages:t.map(([n,r])=>({kind:se,name:n,value:r}))}),this.#c=[],this.#l=new Set(e.observed_properties);for(let n of this.#l)Object.defineProperty(this,n,{get(){return this[`_${n}`]},set(r){this[`_${n}`]=r,this.#n?.send({kind:nt,name:n,value:r})}});e.will_adopt_styles&&await this.#h(),this.#u.mount(e.vdom),this.dispatchEvent(new CustomEvent(\"lustre:mount\"));break}case Ze:{this.#u.push(e.patch,this.#i.length);break}case et:{this.dispatchEvent(new CustomEvent(e.name,{detail:e.data}));break}}}#a(){if(!this.#t||!this.#e)return;this.#n&&this.#n.close();let r={onConnect:()=>{this.#o=!0,this.dispatchEvent(new CustomEvent(\"lustre:connect\"),{detail:{route:this.#t,method:this.#e}})},onMessage:i=>{this.messageReceivedCallback(i)},onClose:()=>{this.#o=!1,this.dispatchEvent(new CustomEvent(\"lustre:close\"),{detail:{route:this.#t,method:this.#e}})}};switch(this.#e){case\"ws\":this.#n=new le(this.#t,r);break;case\"sse\":this.#n=new ae(this.#t,r);break;case\"polling\":this.#n=new fe(this.#t,r);break}}async#h(){for(;this.#i.length;)this.#i.pop().remove(),this.#r.firstChild.remove();this.#i=await Xe(this.#r)}},le=class{#r;#e;#t=!1;#n=[];#s;#i;#u;constructor(e,{onConnect:t,onMessage:n,onClose:r}){this.#r=e,this.#e=new WebSocket(this.#r),this.#s=t,this.#i=n,this.#u=r,this.#e.onopen=()=>{this.#s()},this.#e.onmessage=({data:i})=>{try{this.#i(JSON.parse(i))}finally{this.#n.length?this.#e.send(JSON.stringify({kind:ue,messages:this.#n})):this.#t=!1,this.#n=[]}},this.#e.onclose=()=>{this.#u()}}send(e){if(this.#t){this.#n.push(e);return}else this.#e.send(JSON.stringify(e)),this.#t=!0}close(){this.#e.close()}},ae=class{#r;#e;#t;#n;#s;constructor(e,{onConnect:t,onMessage:n,onClose:r}){this.#r=e,this.#e=new EventSource(this.#r),this.#t=t,this.#n=n,this.#s=r,this.#e.onopen=()=>{this.#t()},this.#e.onmessage=({data:i})=>{try{this.#n(JSON.parse(i))}catch{}}}send(e){}close(){this.#e.close(),this.#s()}},fe=class{#r;#e;#t;#n;#s;#i;constructor(e,{onConnect:t,onMessage:n,onClose:r,...i}){this.#r=e,this.#n=t,this.#s=n,this.#i=r,this.#e=i.interval??5e3,this.#u().finally(()=>{this.#n(),this.#t=window.setInterval(()=>this.#u(),this.#e)})}async send(e){}close(){clearInterval(this.#t),this.#i()}#u(){return fetch(this.#r).then(e=>e.json()).then(this.#s).catch(console.error)}};window.customElements.define(\"lustre-server-component\",oe);export{oe as ServerComponent};\\n",
  )
}

// ATTRIBUTES ------------------------------------------------------------------

/// The `route` attribute tells the client runtime what route it should use to
/// set up the WebSocket connection to the server. Whenever this attribute is
/// changed (by a clientside Lustre app, for example), the client runtime will
/// destroy the current connection and set up a new one.
///
pub fn route(path: String) -> Attribute(msg) {
  attribute("route", path)
}

///
///
pub fn method(value: TransportMethod) -> Attribute(msg) {
  attribute("method", case value {
    WebSocket -> "ws"
    ServerSentEvents -> "sse"
    Polling -> "polling"
  })
}

/// Ocassionally you may want to attach custom data to an event sent to the server.
/// This could be used to include a hash of the current build to detect if the
/// event was sent from a stale client.
///
/// Your event decoders can access this data by decoding `data` property of the
/// event object.
///
pub fn data(json: Json) -> Attribute(msg) {
  json
  |> json.to_string
  |> attribute("data-lustre-data", _)
}

/// Properties of a JavaScript event object are typically not serialisable. This
/// means if we want to pass them to the server we need to copy them into a new
/// object first.
///
/// This attribute tells Lustre what properties to include. Properties can come
/// from nested objects by using dot notation. For example, you could include the
/// `id` of the target `element` by passing `["target.id"]`.
///
/// ```gleam
/// import gleam/dynamic
/// import gleam/result.{try}
/// import lustre/element.{type Element}
/// import lustre/element/html
/// import lustre/event
/// import lustre/server
///
/// pub fn custom_button(on_click: fn(String) -> msg) -> Element(msg) {
///   let handler = fn(event) {
///     use target <- try(dynamic.field("target", dynamic.dynamic)(event))
///     use id <- try(dynamic.field("id", dynamic.string)(target))
///
///     Ok(on_click(id))
///   }
///
///   html.button([event.on_click(handler), server.include(["target.id"])], [
///     element.text("Click me!")
///   ])
/// }
/// ```
///
pub fn include(
  event: Attribute(msg),
  properties: List(String),
) -> Attribute(msg) {
  case event {
    Event(..) -> Event(..event, include: properties)
    _ -> event
  }
}

// ACTIONS ---------------------------------------------------------------------

///
///
pub fn subject(
  runtime: Runtime(msg),
) -> Result(Subject(RuntimeMessage(msg)), Error) {
  do_subject(runtime)
}

@target(erlang)
fn do_subject(
  runtime: Runtime(msg),
) -> Result(Subject(RuntimeMessage(msg)), Error) {
  Ok(coerce(runtime))
}

@target(javascript)
fn do_subject(_: Runtime(msg)) -> Result(Subject(RuntimeMessage(msg)), Error) {
  Error(lustre.NotErlang)
}

@external(erlang, "gleam@function", "identity")
@external(javascript, "../../gleam_stdlib/gleam/function.mjs", "identity")
fn coerce(value: a) -> b

///
///
pub fn register_subject(
  runtime: Subject(RuntimeMessage(msg)),
  client: Subject(ClientMessage(msg)),
) -> Nil {
  do_register_subject(runtime, client)
}

@target(erlang)
fn do_register_subject(
  runtime: Subject(RuntimeMessage(msg)),
  client: Subject(ClientMessage(msg)),
) -> Nil {
  process.send(runtime, runtime.ClientRegisteredSubject(client))
}

@target(javascript)
fn do_register_subject(_, _) -> Nil {
  Nil
}

///
///
pub fn deregister_subject(
  runtime: Subject(RuntimeMessage(msg)),
  client: Subject(ClientMessage(msg)),
) -> Nil {
  do_deregister_subject(runtime, client)
}

@target(erlang)
fn do_deregister_subject(
  runtime: Subject(RuntimeMessage(msg)),
  client: Subject(ClientMessage(msg)),
) -> Nil {
  process.send(runtime, runtime.ClientDeregisteredSubject(client))
}

@target(javascript)
fn do_deregister_subject(_, _) -> Nil {
  Nil
}

///
///
pub fn register_callback(
  runtime: Runtime(msg),
  callback: fn(ClientMessage(msg)) -> Nil,
) -> Nil {
  lustre.send(runtime, runtime.ClientRegisteredCallback(callback))
}

///
///
pub fn deregister_callback(
  runtime: Runtime(msg),
  callback: fn(ClientMessage(msg)) -> Nil,
) -> Nil {
  lustre.send(runtime, runtime.ClientDeregisteredCallback(callback))
}

// EFFECTS ---------------------------------------------------------------------

/// Instruct any connected clients to emit a DOM event with the given name and
/// data. This lets your server component communicate to frontend the same way
/// any other HTML elements do: you might emit a `"change"` event when some part
/// of the server component's state changes, for example.
///
/// This is a real DOM event and any JavaScript on the page can attach an event
/// listener to the server component element and listen for these events.
///
pub fn emit(event: String, data: Json) -> Effect(msg) {
  effect.event(event, data)
}

/// On the Erlang target, Lustre's server component runtime is an OTP
/// [actor](https://hexdocs.pm/gleam_otp/gleam/otp/actor.html) that can be
/// communicated with using the standard process API and the `Subject` returned
/// when starting the server component.
///
/// Sometimes, you might want to hand a different `Subject` to a process to restrict
/// the type of messages it can send or to distinguish messages from different
/// sources from one another. The `select` effect creates a fresh `Subject` each
/// time it is run. By returning a `Selector` you can teach the Lustre server
/// component runtime how to listen to messages from this `Subject`.
///
/// The `select` effect also gives you the dispatch function passed to `effect.from`.
/// This is useful in case you want to store the provided `Subject` in your model
/// for later use. For example you may subscribe to a pubsub service and later use
/// that same `Subject` to unsubscribe.
///
/// **Note**: This effect does nothing on the JavaScript runtime, where `Subject`s
/// and `Selector`s don't exist, and is the equivalent of returning `effect.none`.
///
pub fn select(
  sel: fn(fn(msg) -> Nil, Subject(a)) -> Selector(msg),
) -> Effect(msg) {
  effect.select(sel)
}

// DECODERS --------------------------------------------------------------------

/// The server component client runtime sends JSON encoded actions for the server
/// runtime to execute. Because your own WebSocket server sits between the two
/// parts of the runtime, you need to decode these actions and pass them to the
/// server runtime yourself.
///
/// Encode a DOM patch as JSON you can send to the client runtime to apply. Whenever
/// the server runtime re-renders, all subscribed clients will receive a patch
/// message they must forward to the client runtime.
///
pub fn runtime_message_decoder() -> Decoder(RuntimeMessage(msg)) {
  decode.map(
    transport.server_message_decoder(),
    runtime.ClientDispatchedMessage,
  )
}

// ENCODERS --------------------------------------------------------------------

pub fn client_message_to_json(message: ClientMessage(msg)) -> Json {
  transport.client_message_to_json(message)
}
