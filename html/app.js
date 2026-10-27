const app = document.getElementById('app');
const $ = id => document.getElementById(id);
let players = [], selected = null, view = 'book', maxMonths = 120, minMonths = 1, toastTimer;

const translations = {
  en: {
    policeDatabase:'POLICE DATABASE', operations:'OPERATIONS', book:'Jail a person', release:'Release', secure:'Secure connection',
    eyebrow:'PROCEDURE / ', jail:'JAIL', releaseMode:'RELEASE', selectNearby:'Select a nearby player and enter the sentence details.',
    selectRelease:'Select a nearby player to release from jail.', refresh:'Refresh list', nearby:'Nearby players', distanceNote:'Maximum distance is configured in config.lua.',
    search:'Search by name or ID', searching:'Searching for nearby players ...', noPlayers:'No nearby players found.', noResults:'No search results.',
    listRefresh:'List refreshes on request', sentenceDetails:'Sentence details', required:'All fields are required.', noneSelected:'No player selected', chooseFromList:'Select a person from the list', selected:'SELECTED', notSelected:'NOT SELECTED',
    reason:'Jail reason', reasonPlaceholder:'E.g. obstructing an officer, robbery ...', duration:'Sentence duration', months:'MONTHS', month:'months', monthHint:' months = ', actualMinutes:'In this system, each entered month equals 1 minute of real time.',
    confirm:'Confirm sentence', verify:'Verify the player identity and reason before confirming.', releaseTitle:'Release player', releaseText:'Select a jailed person from the nearby players list, then confirm the release.', releaseButton:'Release from jail',
    internal:'INTERNAL TOOL', hudTitle:'Serving sentence', remaining:'TIME REMAINING', hudReason:'REASON', noReason:'No reason provided',
    noPlayer:'Select a player first.', reasonError:'Enter a reason (at least 3 characters).', durationError:'Duration must be ', sent:'Jail request sent.', releaseSent:'Release request sent.',
    self:'YOU', test:'test selection', playerId:'Player ID ', selectedPrefix:'Selected: ', jailWord:'JAIL', releaseWord:'RELEASE'
  },
  sl: {
    policeDatabase:'POLICIJSKA BAZA', operations:'OPERACIJE', book:'Zapri osebo', release:'Izpustitev', secure:'Varna povezava',
    eyebrow:'KAZENSKI POSTOPEK / ', jail:'ZAPOR', releaseMode:'IZPUSTITEV', selectNearby:'Izberi igralca v bližini in izpolni podatke o kazni.',
    selectRelease:'Izberi igralca v bližini in ga odstrani iz zapora.', refresh:'Osveži seznam', nearby:'Igralci v bližini', distanceNote:'Največja razdalja je določena v configu.',
    search:'Išči po imenu ali ID-ju', searching:'Iskanje igralcev v bližini ...', noPlayers:'V bližini ni najdenih igralcev.', noResults:'Ni rezultatov iskanja.',
    listRefresh:'Seznam se osveži na zahtevo', sentenceDetails:'Podatki o kazni', required:'Vsi podatki so obvezni.', noneSelected:'Noben igralec ni izbran', chooseFromList:'Izberi osebo s seznama', selected:'IZBRAN', notSelected:'NI IZBRAN',
    reason:'Razlog za zapor', reasonPlaceholder:'Npr. oviranje uradne osebe, rop ...', duration:'Trajanje kazni', months:'MESECI', month:'mesecev', monthHint:' mesecev = ', actualMinutes:'V sistemu se vsak vpisan mesec šteje kot 1 minuta dejanskega časa.',
    confirm:'Potrdi zaporno kazen', verify:'Pred potrditvijo preveri identiteto in razlog.', releaseTitle:'Izpustitev igralca', releaseText:'Izberi zaprto osebo s seznama igralcev v bližini, nato potrdi izpustitev.', releaseButton:'Izpusti iz zapora',
    internal:'INTERNO ORODJE', hudTitle:'Prestajaš kazen', remaining:'PREOSTALI ČAS', hudReason:'RAZLOG', noReason:'Ni naveden',
    noPlayer:'Najprej izberi igralca.', reasonError:'Vpiši razlog (vsaj 3 znake).', durationError:'Trajanje mora biti ', sent:'Zahteva za zapor je poslana.', releaseSent:'Zahteva za izpustitev je poslana.',
    self:'TI', test:'testni izbor', playerId:'Igralec ID ', selectedPrefix:'Izbran: ', jailWord:'ZAPOR', releaseWord:'IZPUSTITEV'
  },
  de: {
    policeDatabase:'POLIZEIDATENBANK', operations:'AKTIONEN', book:'Person inhaftieren', release:'Entlassen', secure:'Sichere Verbindung',
    eyebrow:'STRAFVERFAHREN / ', jail:'GEFÄNGNIS', releaseMode:'ENTLASSUNG', selectNearby:'Wähle einen Spieler in der Nähe und gib die Strafe ein.',
    selectRelease:'Wähle einen Spieler in der Nähe zur Entlassung.', refresh:'Liste aktualisieren', nearby:'Spieler in der Nähe', distanceNote:'Maximale Entfernung wird in config.lua festgelegt.',
    search:'Nach Name oder ID suchen', searching:'Suche nach Spielern in der Nähe ...', noPlayers:'Keine Spieler in der Nähe gefunden.', noResults:'Keine Suchergebnisse.',
    listRefresh:'Liste wird auf Anfrage aktualisiert', sentenceDetails:'Strafdetails', required:'Alle Felder sind erforderlich.', noneSelected:'Kein Spieler ausgewählt', chooseFromList:'Wähle eine Person aus der Liste', selected:'AUSGEWÄHLT', notSelected:'NICHT AUSGEWÄHLT',
    reason:'Haftgrund', reasonPlaceholder:'Z. B. Behinderung eines Beamten, Raub ...', duration:'Haftdauer', months:'MONATE', month:'Monate', monthHint:' Monate = ', actualMinutes:'Jeder eingegebene Monat entspricht einer realen Minute.',
    confirm:'Haft bestätigen', verify:'Identität und Grund vor der Bestätigung prüfen.', releaseTitle:'Spieler entlassen', releaseText:'Wähle einen inhaftierten Spieler aus der Liste und bestätige die Entlassung.', releaseButton:'Aus dem Gefängnis entlassen',
    internal:'INTERNES TOOL', hudTitle:'Haftstrafe wird verbüßt', remaining:'VERBLEIBENDE ZEIT', hudReason:'GRUND', noReason:'Kein Grund angegeben',
    noPlayer:'Wähle zuerst einen Spieler.', reasonError:'Grund eingeben (mindestens 3 Zeichen).', durationError:'Dauer muss zwischen ', sent:'Haftanfrage gesendet.', releaseSent:'Entlassungsanfrage gesendet.',
    self:'DU', test:'Testauswahl', playerId:'Spieler-ID ', selectedPrefix:'Ausgewählt: ', jailWord:'HAFT', releaseWord:'ENTLASSUNG'
  },
  hr: {
    policeDatabase:'POLICIJSKA BAZA', operations:'RADNJE', book:'Zatvori osobu', release:'Otpusti', secure:'Sigurna veza',
    eyebrow:'KAZNENI POSTUPAK / ', jail:'ZATVOR', releaseMode:'OTPUŠTANJE', selectNearby:'Odaberi obližnjeg igrača i unesi podatke o kazni.',
    selectRelease:'Odaberi obližnjeg igrača za otpuštanje iz zatvora.', refresh:'Osvježi popis', nearby:'Igrači u blizini', distanceNote:'Maksimalna udaljenost postavlja se u config.lua.',
    search:'Pretraži po imenu ili ID-u', searching:'Traženje obližnjih igrača ...', noPlayers:'Nema igrača u blizini.', noResults:'Nema rezultata pretraživanja.',
    listRefresh:'Popis se osvježava na zahtjev', sentenceDetails:'Podaci o kazni', required:'Sva polja su obavezna.', noneSelected:'Nijedan igrač nije odabran', chooseFromList:'Odaberi osobu s popisa', selected:'ODABRAN', notSelected:'NIJE ODABRAN',
    reason:'Razlog zatvora', reasonPlaceholder:'Npr. ometanje službene osobe, pljačka ...', duration:'Trajanje kazne', months:'MJESECI', month:'mjeseci', monthHint:' mjeseci = ', actualMinutes:'Svaki uneseni mjesec računa se kao 1 minuta stvarnog vremena.',
    confirm:'Potvrdi kaznu', verify:'Prije potvrde provjeri identitet i razlog.', releaseTitle:'Otpusti igrača', releaseText:'Odaberi zatvorenu osobu s popisa obližnjih igrača i potvrdi otpuštanje.', releaseButton:'Otpusti iz zatvora',
    internal:'INTERNO OROĐE', hudTitle:'Izdržavaš kaznu', remaining:'PREOSTALO VRIJEME', hudReason:'RAZLOG', noReason:'Razlog nije naveden',
    noPlayer:'Prvo odaberi igrača.', reasonError:'Unesi razlog (najmanje 3 znaka).', durationError:'Trajanje mora biti ', sent:'Zahtjev za zatvor je poslan.', releaseSent:'Zahtjev za otpuštanje je poslan.',
    self:'TI', test:'testni odabir', playerId:'Igrač ID ', selectedPrefix:'Odabran: ', jailWord:'ZATVOR', releaseWord:'OTPUŠTANJE'
  }
};
let locale = 'en';
function applyLocale(code){
  locale = translations[code] ? code : 'en';
  const t = translations[locale]; document.documentElement.lang = locale;
  const set=(sel,key)=>{const el=document.querySelector(sel);if(el&&t[key])el.textContent=t[key]};
  const setHtml=(sel,key,html)=>{const el=document.querySelector(sel);if(el&&t[key])el.innerHTML=html||t[key]};
  set('.secure','policeDatabase'); set('.side-label','operations');
  const nav=document.querySelectorAll('.nav'); if(nav[0])nav[0].innerHTML='<span class="nav-icon">▤</span> '+t.book; if(nav[1])nav[1].innerHTML='<span class="nav-icon">↗</span> '+t.release;
  set('.sidebar-note strong','secure'); const eyebrow=document.querySelector('.page-head .eyebrow'); if(eyebrow) eyebrow.innerHTML=t.eyebrow+'<span id="modeLabel">'+(view==='book'?t.jail:t.releaseMode)+'</span>'; 
  set('.refresh','refresh'); set('.people-card .card-head h3','nearby'); set('.people-card .card-head p','distanceNote');
  $('search').placeholder=t.search; set('.list-foot','listRefresh'); set('.form-card .card-head h3','sentenceDetails'); set('.form-card .card-head p','required');
  const selectedEl=$('selectedPerson'); if(selectedEl){selectedEl.querySelector('strong').textContent=t.noneSelected;selectedEl.querySelector('small').textContent=t.chooseFromList;selectedEl.querySelector('.selection-pill').textContent=t.notSelected;}
  set('label[for="reason"]','reason'); $('reason').placeholder=t.reasonPlaceholder; set('label[for="months"]','duration'); set('.field-row .unit','months'); set('.duration-side strong','month');
  set('.notice p','actualMinutes'); set('#jailBtn','confirm'); set('.form-foot','verify'); set('#releaseView h3','releaseTitle'); set('#releaseView p','releaseText'); set('#releaseBtn','releaseButton');
  set('.hud-top strong','hudTitle'); set('.hud-label','remaining'); set('.hud-reason small','hudReason');
  if(view==='book'){$('modeLabel').textContent=t.jail;$('pageTitle').textContent=t.book;$('pageSub').textContent=t.selectNearby;}else{$('modeLabel').textContent=t.releaseMode;$('pageTitle').textContent=t.release;$('pageSub').textContent=t.selectRelease;}
  $('minutesHint').textContent=`${$('months').value} ${t.monthHint}`.replace(t.monthHint, t.monthHint+`${$('months').value} ${locale==='en'?'minutes':locale==='de'?'Minuten':locale==='hr'?'minute':'minut'}`);
}
const nui = (name, data = {}) => fetch(`https://${GetParentResourceName()}/${name}`, { method:'POST', headers:{'Content-Type':'application/json; charset=UTF-8'}, body:JSON.stringify(data) }).catch(()=>{});
function notify(message){const el=$('toast');el.textContent=message;el.style.display='block';clearTimeout(toastTimer);toastTimer=setTimeout(()=>el.style.display='none',2800)}
function initials(name){return String(name||'?').trim().split(/\s+/).slice(0,2).map(x=>x[0]||'').join('').toUpperCase()||'?'}
function renderPlayers(){const query=$('search').value.trim().toLowerCase();const filtered=players.filter(p=>String(p.name).toLowerCase().includes(query)||String(p.id).includes(query));$('playerCount').textContent=filtered.length;$('players').innerHTML='';if(!filtered.length){$('players').innerHTML=`<div class="empty">${players.length?translations[locale].noResults:translations[locale].noPlayers}</div>`;return}filtered.forEach(p=>{const row=document.createElement('div');row.className='player-row'+(selected&&selected.id===p.id?' selected':'');row.innerHTML=`<div class="avatar">${initials(p.name)}</div><div class="player-info"><strong></strong><small>ID ${p.id}${p.self?' · '+translations[locale].test:''}</small></div>${p.self?'<span class="self-tag">'+translations[locale].self+'</span>':''}<span class="distance">${Number(p.distance).toFixed(1)} m</span>`;row.querySelector('.player-info strong').textContent=p.name;row.onclick=()=>choose(p);$('players').appendChild(row)})}
function choose(p){selected=p;const el=$('selectedPerson');el.querySelector('.avatar').textContent=initials(p.name);el.querySelector('strong').textContent=p.name;el.querySelector('small').textContent=`Igralec ID ${p.id}${p.self?' · '+translations[locale].test:''}`;const pill=el.querySelector('.selection-pill');pill.textContent=translations[locale].selected;pill.classList.add('chosen');$('jailBtn').disabled=false;$('releaseBtn').disabled=false;$('releaseSelected').textContent=`Izbran: ${p.name} (ID ${p.id})`;renderPlayers()}
function setView(next){view=next;document.querySelectorAll('.nav').forEach(b=>b.classList.toggle('active',b.dataset.view===next));$('columns').style.display=next==='book'?'grid':'none';$('releaseView').classList.toggle('hidden',next!=='release');$('modeLabel').textContent=next==='book'?translations[locale].jail:translations[locale].releaseMode;$('pageTitle').textContent=next==='book'?translations[locale].book:translations[locale].release;$('pageSub').textContent=next==='book'?translations[locale].selectNearby:translations[locale].selectRelease}
window.addEventListener('message',e=>{const d=e.data||{};if(d.action==='open'){app.classList.remove('hidden');$('serverName').textContent=d.serverName||'SMRKEC POLICE';$('menuTitle').textContent=d.title||'Jail System';applyLocale(d.locale||'en');setView('book');applyLocale(d.locale||'en')}if(d.action==='players'){players=d.players||[];maxMonths=Number(d.maxMonths)||120;minMonths=Number(d.minMonths)||1;$('months').max=maxMonths;$('months').min=minMonths;renderPlayers()}if(d.action==='jailStatus'){const hud=$('jailHud');hud.classList.toggle('hidden',!d.jailed);if(d.jailed){$('hudReason').textContent=d.reason||'Ni naveden';updateTime(d.remaining)}}if(d.action==='time')updateTime(d.remaining)});
function close(){app.classList.add('hidden');nui('close')}
$('close').onclick=close;document.addEventListener('keydown',e=>{if(e.key==='Escape'){if(!app.classList.contains('hidden'))close()}});$('refresh').onclick=()=>nui('refresh');$('search').addEventListener('input',renderPlayers);document.querySelectorAll('.nav').forEach(b=>b.onclick=()=>setView(b.dataset.view));$('months').addEventListener('input',()=>{let n=Math.max(0,Number($('months').value)||0);$('minutesHint').textContent=`${n} mesecev = ${n} minut`});$('jailBtn').onclick=()=>{if(!selected)return notify(translations[locale].noPlayer);const reason=$('reason').value.trim(),months=Number($('months').value);if(reason.length<3)return notify(translations[locale].reasonError);if(!Number.isInteger(months)||months<minMonths||months>maxMonths)return notify(`Trajanje mora biti ${minMonths}–${maxMonths} mesecev.`);nui('jail',{id:selected.id,reason,months});notify(translations[locale].sent);};$('releaseBtn').onclick=()=>{if(!selected)return notify(translations[locale].noPlayer);nui('release',{id:selected.id});notify(translations[locale].releaseSent)};function updateTime(seconds){let s=Math.max(0,Number(seconds)||0),m=Math.floor(s/60),r=s%60;$('hudTime').textContent=String(m).padStart(2,'0')+':'+String(r).padStart(2,'0')}
