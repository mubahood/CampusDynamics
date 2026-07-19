<%@ Page Language="C#" MasterPageFile="~/COOPERP/NewScreens/SidebarMaster.master" AutoEventWireup="true" CodeFile="AlumniDataBank.aspx.cs" Inherits="COOPERP_NewScreens_AlumniDataBank" Title="Alumni Data Bank - Campus Dynamics" %>
<asp:Content ID="H" ContentPlaceHolderID="HeadContent" runat="server">
<style>
/* ===== ALUMNI DATA BANK (prefix adb-) ================================== */
.adb-hdr{display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;padding:12px 14px;background:#fff;border-bottom:1px solid #e0e5ed;}
.adb-hdr__l{display:flex;align-items:center;gap:10px;}
.adb-hdr__ic{width:34px;height:34px;background:#05275C;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.adb-hdr__t{font-size:16px;font-weight:800;color:#05275C;line-height:1.1;}
.adb-hdr__s{font-size:10.5px;color:#6b7280;margin-top:1px;}
.adb-hdr__act{display:flex;gap:6px;flex-wrap:wrap;}
.adb-btn{display:inline-flex;align-items:center;gap:5px;padding:6px 12px;border:1px solid #d2dae6;background:#fff;color:#05275C;text-decoration:none;font-size:11.5px;font-weight:700;cursor:pointer;font-family:inherit;height:31px;box-sizing:border-box;}
.adb-btn:hover{border-color:#174DA4;color:#174DA4;}
.adb-btn--p{background:#05275C;border-color:#05275C;color:#fff;}.adb-btn--p:hover{background:#174DA4;border-color:#174DA4;color:#fff;}
/* stats */
.adb-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:8px;padding:12px 14px;background:#fafbfc;border-bottom:1px solid #e0e5ed;}
.adb-stat{background:#fff;border:1px solid #e0e5ed;padding:9px 13px;position:relative;overflow:hidden;}
.adb-stat::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:var(--c,#94a3b8);}
.adb-stat__n{font-size:20px;font-weight:800;color:var(--c,#05275C);line-height:1;font-variant-numeric:tabular-nums;}
.adb-stat__l{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:#94a3b8;margin-bottom:3px;}
.adb-stat__sub{font-size:9.5px;color:#94a3b8;font-weight:600;margin-top:3px;}
.adb-stat--total{--c:#174DA4;} .adb-stat--phone{--c:#16a34a;} .adb-stat--email{--c:#7c3aed;} .adb-stat--grad{--c:#05275C;} .adb-stat--progs{--c:#e65100;}
/* filters */
.adb-filters{padding:10px 14px;background:#f8f9fa;border-bottom:1px solid #e0e5ed;display:flex;gap:7px;align-items:flex-end;flex-wrap:wrap;}
.adb-fl{display:flex;flex-direction:column;gap:2px;}
.adb-fl>span{font-size:8px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#9aa6b8;padding-left:1px;}
.adb-sel,.adb-in{border:1px solid #cfd8e3;background:#fff;padding:6px 9px;font-size:12px;color:#1f2937;font-family:inherit;height:31px;box-sizing:border-box;}
.adb-sel:focus,.adb-in:focus{outline:none;border-color:#174DA4;}
.adb-search{min-width:230px;}
.adb-chk{display:flex;align-items:center;gap:5px;font-size:11px;color:#374151;cursor:pointer;height:31px;user-select:none;}
.adb-chk input{width:14px;height:14px;accent-color:#174DA4;cursor:pointer;}
.adb-fl__sp{flex:1;}
.adb-count{font-size:11px;color:#174DA4;font-weight:700;background:rgba(23,77,164,.07);padding:5px 10px;}
/* searchable combo */
.adb-combo{position:relative;display:inline-block;min-width:150px;}
.adb-combo__inp{width:100%;box-sizing:border-box;}
.adb-combo__list{position:absolute;top:100%;left:0;z-index:9000;background:#fff;border:1px solid #cfd8e3;max-height:260px;overflow:auto;display:none;box-shadow:0 6px 18px rgba(0,0,0,.13);min-width:240px;}
.adb-combo__list.on{display:block;}
.adb-combo__i{padding:7px 10px;font-size:12px;cursor:pointer;border-bottom:1px solid #f0f2f5;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.adb-combo__i:hover{background:#eef4ff;} .adb-combo__i--none{color:#9ca3af;cursor:default;}
/* table */
.adb-wrap{overflow-x:auto;}
.adb-table{width:100%;border-collapse:collapse;font-size:11.5px;}
.adb-table th{background:#f5f7fa;padding:8px 12px;text-align:left;font-size:10px;text-transform:uppercase;letter-spacing:.3px;color:#666;font-weight:700;border-bottom:2px solid #e0e5ed;white-space:nowrap;}
.adb-table td{padding:7px 12px;border-bottom:1px solid #f0f2f5;color:#1a1a2e;vertical-align:middle;}
.adb-table tbody tr{cursor:pointer;}
.adb-table tbody tr:hover td{background:#f5f9ff;}
.adb-rank{color:#b0b8c6;font-size:10px;font-weight:700;text-align:center;width:34px;}
.adb-name{font-weight:700;color:#05275C;}
.adb-mono{font-family:monospace;font-size:11px;color:#555;}
.adb-num{text-align:center;font-variant-numeric:tabular-nums;}
.adb-sub{font-size:9.5px;color:#94a3b8;font-weight:600;}
.adb-mut{color:#c3ccda;}
.adb-table a{color:#174DA4;text-decoration:none;} .adb-table a:hover{text-decoration:underline;}
.adb-empty{text-align:center;color:#94a3b8;padding:34px;font-size:13px;}
/* pager */
.adb-pager{display:flex;align-items:center;justify-content:space-between;padding:10px 14px;border-top:1px solid #e0e5ed;font-size:11px;color:#666;background:#fafbfc;flex-wrap:wrap;gap:8px;}
.adb-pager__nav{display:flex;gap:4px;}
.adb-pg{border:1px solid #ddd;background:#fff;padding:4px 11px;font-size:11px;cursor:pointer;color:#333;text-decoration:none;}
.adb-pg:hover{background:#f0f4ff;border-color:#174DA4;}
.adb-pg--cur{background:#05275C;color:#fff;border-color:#05275C;cursor:default;}
/* detail drawer */
.ad-ov{position:fixed;inset:0;background:rgba(9,20,40,.44);z-index:1000;display:none;justify-content:flex-end;}
.ad-ov.on{display:flex;}
.ad-dr{width:460px;max-width:96vw;height:100%;background:#f5f7fa;box-shadow:-8px 0 28px rgba(0,0,0,.22);overflow-y:auto;position:relative;animation:adsl .18s ease-out;}
@keyframes adsl{from{transform:translateX(26px);opacity:.4;}to{transform:translateX(0);opacity:1;}}
.ad-x{position:absolute;top:10px;right:10px;z-index:2;width:30px;height:30px;border:0;background:rgba(255,255,255,.18);color:#fff;font-size:20px;cursor:pointer;}
.ad-x:hover{background:rgba(255,255,255,.34);}
.ad-top{padding:20px 20px 16px;color:#fff;background:#05275C;}
.ad-top .nm{font-size:20px;font-weight:800;letter-spacing:-.2px;}
.ad-top .rg{font-family:monospace;font-size:12px;opacity:.85;margin-top:3px;}
.ad-top .gd{display:inline-block;margin-top:8px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;background:#16a34a;padding:3px 9px;}
.ad-sec{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:#05275C;background:#eef2f8;padding:6px 20px;border-top:1px solid #e0e5ed;}
.ad-grid{background:#fff;padding:12px 20px;display:grid;grid-template-columns:1fr 1fr;gap:10px 16px;}
.ad-f label{display:block;font-size:9px;text-transform:uppercase;letter-spacing:.4px;color:#94a3b8;font-weight:700;margin-bottom:2px;}
.ad-f .v{font-size:12.5px;color:#1a1a2e;font-weight:600;word-break:break-word;line-height:1.4;}
.ad-f .v.na{color:#c3ccda;font-weight:400;font-style:italic;}
.ad-f.s2{grid-column:span 2;}
.ad-acts{padding:14px 20px 22px;display:flex;flex-direction:column;gap:8px;background:#fff;}
.ad-abtn{display:flex;align-items:center;justify-content:center;gap:8px;font-size:12.5px;font-weight:700;padding:11px;text-decoration:none;border:1px solid #cdd8e6;background:#fff;color:#05275C;cursor:pointer;font-family:inherit;}
.ad-abtn:hover{border-color:#174DA4;color:#174DA4;}
.ad-abtn--p{background:#05275C;border-color:#05275C;color:#fff;}.ad-abtn--p:hover{background:#174DA4;border-color:#174DA4;}
.ad-load{padding:40px;text-align:center;color:#94a3b8;font-size:12px;}
</style>
</asp:Content>

<asp:Content ID="C" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="adb-hdr">
  <div class="adb-hdr__l">
    <div class="adb-hdr__ic"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg></div>
    <div><div class="adb-hdr__t">Alumni Data Bank</div><div class="adb-hdr__s">Contact &amp; address directory of graduated / alumni students</div></div>
  </div>
  <div class="adb-hdr__act">
    <a class="adb-btn" href='AlumniDataBank.aspx?<%= CurrentFilterQS() %>export=csv'>&#8681; Export CSV</a>
    <button type="button" class="adb-btn adb-btn--p" onclick="ADB.print()">&#128424; Print page</button>
  </div>
</div>

<%= litStats %>

<div class="adb-filters">
  <div class="adb-fl"><span>Search</span><input type="text" id="fq" class="adb-in adb-search" placeholder="Name, reg no, phone, email…" value="<%= HE(FQ) %>" onkeydown="if(event.key==='Enter'){apply();}"></div>
  <div class="adb-fl" style="min-width:190px;"><span>Programme</span><select id="fprog" class="adb-sel"><option value="">All programmes</option><%= litProgOptions %></select></div>
  <div class="adb-fl" style="min-width:170px;"><span>Faculty</span><select id="ffac" class="adb-sel"><option value="">All faculties</option><%= litFacOptions %></select></div>
  <div class="adb-fl"><span>Grad year</span><select id="fgy" class="adb-sel"><option value="">Any</option><%= litGradYearOptions %></select></div>
  <div class="adb-fl"><span>Entry year</span><select id="fey" class="adb-sel"><option value="">Any</option><%= litEntryYearOptions %></select></div>
  <div class="adb-fl"><span>Campus</span><select id="fcampus" class="adb-sel"><option value="">All</option><%= litCampusOptions %></select></div>
  <div class="adb-fl"><span>Gender</span><select id="fgender" class="adb-sel"><option value="">All</option><option value="MALE"<%= Sel(FGender,"MALE") %>>Male</option><option value="FEMALE"<%= Sel(FGender,"FEMALE") %>>Female</option></select></div>
  <div class="adb-fl"><span>Session</span><select id="fsession" class="adb-sel"><option value="">All</option><option value="DAY"<%= Sel(FSession,"DAY") %>>Day</option><option value="WEEKEND"<%= Sel(FSession,"WEEKEND") %>>Weekend</option><option value="INSERVICE"<%= Sel(FSession,"INSERVICE") %>>In-service</option><option value="EVENING"<%= Sel(FSession,"EVENING") %>>Evening</option></select></div>
  <div class="adb-fl"><span>&nbsp;</span><label class="adb-chk"><input type="checkbox" id="fhp" <%= FHasPhone=="1"?"checked":"" %>> Has phone</label></div>
  <div class="adb-fl"><span>&nbsp;</span><label class="adb-chk"><input type="checkbox" id="fhe" <%= FHasEmail=="1"?"checked":"" %>> Has email</label></div>
  <div class="adb-fl__sp"></div>
  <div class="adb-fl"><span>Per page</span><select id="fsize" class="adb-sel" onchange="apply()"><option value="25"<%= Sel(FSize.ToString(),"25") %>>25</option><option value="50"<%= Sel(FSize.ToString(),"50") %>>50</option><option value="100"<%= Sel(FSize.ToString(),"100") %>>100</option><option value="200"<%= Sel(FSize.ToString(),"200") %>>200</option><option value="500"<%= Sel(FSize.ToString(),"500") %>>500</option></select></div>
  <div class="adb-fl"><span>&nbsp;</span><button type="button" class="adb-btn adb-btn--p" onclick="apply()">Apply</button></div>
  <div class="adb-fl"><span>&nbsp;</span><button type="button" class="adb-btn" onclick="clr()">Clear</button></div>
  <div class="adb-fl"><span>&nbsp;</span><span class="adb-count"><%= litCount %></span></div>
</div>

<div class="adb-wrap">
  <table class="adb-table" id="adbTable">
    <thead><tr><th class="adb-rank">#</th><th>Name</th><th>Reg No</th><th>Programme</th><th>Gender</th><th>Phone</th><th>Email</th><th>District</th><th class="adb-num">Grad Year</th><th class="adb-num">Entry</th></tr></thead>
    <tbody><%= litTableRows %></tbody>
  </table>
</div>
<%= litPager %>

<div class="ad-ov" id="adOv"><div class="ad-dr"><button type="button" class="ad-x" onclick="ADB.close()">&times;</button><div class="ad-body"><div class="ad-load">Loading…</div></div></div></div>

<script>
var ADB = (function(){
  function qs(id){return document.getElementById(id);}
  function esc(s){s=(s==null?'':''+s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  function v(x){ return (x!==null&&x!==undefined&&(''+x).trim().length&&x!=='-')?(''+x):null; }

  // searchable dropdown enhancer
  function enhance(sel){
    if(!sel||sel._e) return; sel._e=true;
    var opts=[]; for(var i=0;i<sel.options.length;i++) opts.push({v:sel.options[i].value,t:sel.options[i].text});
    var wrap=document.createElement('div'); wrap.className='adb-combo'; if(sel.style.minWidth) wrap.style.minWidth=sel.style.minWidth;
    sel.parentNode.insertBefore(wrap,sel); wrap.appendChild(sel); sel.style.display='none';
    var inp=document.createElement('input'); inp.type='text'; inp.className='adb-combo__inp adb-in'; inp.autocomplete='off'; inp.placeholder=opts[0]?opts[0].t:'Search…';
    var list=document.createElement('div'); list.className='adb-combo__list'; wrap.appendChild(inp); wrap.appendChild(list);
    var cur=opts.filter(function(o){return String(o.v)===String(sel.value);})[0]; if(cur&&cur.v) inp.value=cur.t;
    function draw(f){ f=(f||'').toLowerCase(); var m=opts.filter(function(o){return !f||o.t.toLowerCase().indexOf(f)>=0;});
      if(!m.length){ list.innerHTML='<div class="adb-combo__i adb-combo__i--none">No match</div>'; return; }
      list.innerHTML=m.slice(0,150).map(function(o){return '<div class="adb-combo__i" data-v="'+esc(o.v)+'">'+esc(o.t)+'</div>';}).join('');
      [].forEach.call(list.querySelectorAll('.adb-combo__i[data-v]'),function(el){ el.onmousedown=function(e){ e.preventDefault(); sel.value=el.getAttribute('data-v'); inp.value=el.textContent; list.classList.remove('on'); }; });
    }
    inp.addEventListener('focus',function(){ draw(''); list.classList.add('on'); });
    inp.addEventListener('input',function(){ sel.value=''; draw(inp.value); list.classList.add('on'); });
    inp.addEventListener('keydown',function(e){ if(e.key==='Enter'){ e.preventDefault(); var f=list.querySelector('.adb-combo__i[data-v]'); if(f){ sel.value=f.getAttribute('data-v'); inp.value=f.textContent; } list.classList.remove('on'); apply(); } });
    inp.addEventListener('blur',function(){ setTimeout(function(){ list.classList.remove('on'); },160); });
  }
  enhance(qs('fprog')); enhance(qs('ffac'));

  function apply(){
    var sp=new URLSearchParams();
    function a(k,val){ if(val) sp.set(k,val); }
    a('q',(qs('fq').value||'').trim()); a('prog',qs('fprog').value); a('fac',qs('ffac').value);
    a('gradYear',qs('fgy').value); a('entryYear',qs('fey').value); a('campus',qs('fcampus').value);
    a('gender',qs('fgender').value); a('session',qs('fsession').value);
    if(qs('fhp').checked) sp.set('hasPhone','1'); if(qs('fhe').checked) sp.set('hasEmail','1');
    if(qs('fsize').value!=='50') sp.set('size',qs('fsize').value);
    var s=sp.toString(); location.href=location.pathname+(s?'?'+s:'');
  }
  function clr(){ location.href=location.pathname; }

  /* detail drawer */
  function detail(regno){
    qs('adOv').classList.add('on');
    qs('adOv').querySelector('.ad-body').innerHTML='<div class="ad-load">Loading…</div>';
    fetch('AlumniDataBank.aspx?ajax=detail&regno='+encodeURIComponent(regno)).then(function(r){return r.json();}).then(function(d){
      if(!d||!d.ok){ qs('adOv').querySelector('.ad-body').innerHTML='<div class="ad-load">'+esc((d&&d.error)||'Not found')+'</div>'; return; }
      render(d);
    }).catch(function(){ qs('adOv').querySelector('.ad-body').innerHTML='<div class="ad-load">Failed to load.</div>'; });
  }
  function f(label,val,span){ var na=v(val)==null; return '<div class="ad-f'+(span?' s2':'')+'"><label>'+label+'</label><div class="v'+(na?' na':'')+'">'+(na?'—':esc(val))+'</div></div>'; }
  function render(d){
    var h='<div class="ad-top"><div class="nm">'+esc(d.name||'—')+'</div><div class="rg">'+esc(d.regno)+'</div>'
      +(v(d.gradYear)?'<span class="gd">Graduated '+esc(d.gradYear)+(v(d.gradClass)?' · '+esc(d.gradClass):'')+'</span>':'')+'</div>';
    h+='<div class="ad-sec">Contact &amp; Address</div><div class="ad-grid">'
      +f('Phone',d.phone)+f('Alt. phone',d.altPhone)
      +f('Email',d.email,true)
      +f('Physical / Postal address',d.phyAddress,true)
      +f('P.O. Box',d.postBox)+f('Home district',v(d.district)||d.homeDistrict)
      +f('Residence country',d.residenceCountry)+f('Nationality',d.nationality)
      +f('Residence hall',d.hall)+f('Next-of-kin contact',d.kinContacts,true)
      +'</div>';
    h+='<div class="ad-sec">Academic</div><div class="ad-grid">'
      +f('Programme',d.programme,true)+f('Faculty',d.faculty,true)
      +f('Specialisation',d.specialisation,true)
      +f('Entry year',d.entryYear)+f('Session',d.session)
      +f('Campus',d.campus)+f('Intake',d.intake)+f('Entry method',d.entryMethod)
      +'</div>';
    h+='<div class="ad-sec">Graduation</div><div class="ad-grid">'
      +f('Graduation year',d.gradYear)+f('Degree classification',d.gradClass)
      +f('CGPA',d.cgpa)+f('Academic year',d.acadYear)
      +f('Graduation date',d.gradDate)+f('Ceremony',d.convocation,true)
      +'</div>';
    h+='<div class="ad-acts">';
    if(v(d.phone)) h+='<a class="ad-abtn ad-abtn--p" href="tel:'+esc(d.phone)+'">Call '+esc(d.phone)+'</a>';
    if(v(d.email)) h+='<a class="ad-abtn" href="mailto:'+esc(d.email)+'">Email</a>';
    h+='</div>';
    qs('adOv').querySelector('.ad-body').innerHTML=h;
  }
  function close(){ qs('adOv').classList.remove('on'); }
  qs('adOv').addEventListener('click',function(e){ if(e.target===qs('adOv')) close(); });
  document.addEventListener('keydown',function(e){ if(e.key==='Escape') close(); });

  /* branded print of the current page */
  function print(){
    var rows=[].slice.call(document.querySelectorAll('#adbTable tbody tr')).filter(function(tr){ return !tr.querySelector('.adb-empty'); });
    if(!rows.length){ alert('Nothing to print.'); return; }
    var body='';
    rows.forEach(function(tr,i){
      var td=tr.children; function tx(n){ return td[n]?td[n].textContent.trim():''; }
      body+='<tr><td class="n">'+(i+1)+'</td><td><b>'+esc(tx(1))+'</b></td><td>'+esc(tx(2))+'</td><td>'+esc(tx(3))+'</td><td>'+esc(tx(4))+'</td><td>'+esc(tx(5))+'</td><td>'+esc(tx(6))+'</td><td>'+esc(tx(7))+'</td><td class="c">'+esc(tx(8))+'</td></tr>';
    });
    var now=new Date(), MON=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var stamp=now.getDate()+' '+MON[now.getMonth()]+' '+now.getFullYear();
    var logo=(location.origin||'')+'/COOPERP/images/welcomelogo.png';
    var css='@page{size:A4 landscape;margin:11mm;}*{box-sizing:border-box;}body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;color:#1a1a2e;margin:0;font-size:10px;}'
      +'.hd{display:flex;align-items:center;gap:13px;border-bottom:3px solid #05275C;padding-bottom:8px;margin-bottom:10px;}.hd img{height:44px;}'
      +'.hd .u{font-size:15px;font-weight:800;color:#05275C;}.hd .t{font-size:12px;font-weight:700;color:#174DA4;margin-top:2px;}.hd .m{font-size:9px;color:#555;margin-top:2px;}'
      +'table{width:100%;border-collapse:collapse;}tr{page-break-inside:avoid;}thead th{background:#05275C;color:#fff;text-align:left;font-size:8px;font-weight:800;text-transform:uppercase;letter-spacing:.3px;padding:4px 6px;}th.c,td.c{text-align:center;}'
      +'td{padding:3px 6px;border-bottom:1px solid #edf1f6;font-size:9.5px;}td.n{color:#94a3b8;}td b{color:#05275C;}tbody tr:nth-child(even) td{background:#fafbfd;}'
      +'.ft{margin-top:6px;border-top:1px solid #e0e5ed;padding-top:6px;font-size:9px;color:#94a3b8;display:flex;justify-content:space-between;}';
    var html='<!doctype html><html><head><meta charset="utf-8"><title>Alumni Data Bank</title><style>'+css+'</style></head><body>'
      +'<div class="hd"><img src="'+logo+'" onerror="this.style.display=\'none\'" alt=""/><div><div class="u">Muteesa I Royal University</div><div class="t">Alumni Data Bank</div><div class="m">'+rows.length+' alumni · this page</div></div></div>'
      +'<table><thead><tr><th>#</th><th>Name</th><th>Reg No</th><th>Programme</th><th>Gender</th><th>Phone</th><th>Email</th><th>District</th><th class="c">Grad Yr</th></tr></thead><tbody>'+body+'</tbody></table>'
      +'<div class="ft"><span>Generated '+stamp+'</span><span>eadmin.mru.ac.ug</span></div></body></html>';
    var w=window.open('','_blank'); if(!w){ alert('Please allow pop-ups.'); return; }
    w.document.open(); w.document.write(html); w.document.close(); w.focus(); setTimeout(function(){ try{w.print();}catch(e){} },350);
  }

  window.apply=apply; window.clr=clr;
  return { detail:detail, close:close, print:print };
})();
</script>
</asp:Content>
