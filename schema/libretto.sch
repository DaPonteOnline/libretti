<?xml version="1.0" encoding="UTF-8"?>
<!--
  libretto.sch — Project Schematron rules.

  Loaded by scripts/validate_tei.py via lxml.isoschematron (XPath 1.0 only).
  More complex checks (multi-token @who, regex patterns, @who broken-with-suggestions,
  Italian taxonomy whitelist, fuzzy ref matching) are implemented as custom Python
  checks in validate_tei.py — they require XPath 2.0 features lxml doesn't support.

  Severity codes:
    role="error"   — hard fail; blocks build in CI
    role="warning" — visible in health report; doesn't block
    role="info"    — visible in health report; expected for Tier B
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron">

  <sch:title>Da Ponte Libretti — project Schematron rules</sch:title>

  <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>

  <!-- ═══════════════════════════════════════════════════════════
       PATTERN 1 — teiHeader essentials
       ═══════════════════════════════════════════════════════════ -->
  <sch:pattern id="header-essentials">

    <sch:rule context="tei:teiHeader/tei:fileDesc/tei:titleStmt">
      <sch:assert test="tei:author or tei:respStmt"
                  role="error">[HEADER_AUTHOR] 
        Ogni edizione deve dichiarare un &lt;author&gt; o &lt;respStmt&gt; in &lt;titleStmt&gt;.
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:profileDesc">
      <sch:assert test="tei:langUsage/tei:language[@ident]"
                  role="error">[LANG_USAGE_REQUIRED] 
        &lt;profileDesc&gt; deve contenere &lt;langUsage&gt; con almeno una &lt;language @ident&gt;.
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:language">
      <sch:assert test="string-length(@ident) = 3"
                  role="error">[LANG_ISO_639_3] 
        Codice lingua "<sch:value-of select="@ident"/>" deve essere ISO 639-3 a 3 lettere (es. "ita", non "it").
      </sch:assert>
    </sch:rule>

  </sch:pattern>

  <!-- ═══════════════════════════════════════════════════════════
       PATTERN 2 — Required IDs
       ═══════════════════════════════════════════════════════════ -->
  <sch:pattern id="required-ids">

    <sch:rule context="tei:witness">
      <sch:assert test="@xml:id" role="error">[WITNESS_NO_ID] 
        Ogni &lt;witness&gt; deve avere @xml:id (siglum).
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:person">
      <sch:assert test="@xml:id" role="error">[PERSON_NO_ID] 
        Ogni &lt;person&gt; deve avere @xml:id.
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:personGrp">
      <sch:assert test="@xml:id" role="error">[PERSONGRP_NO_ID] 
        Ogni &lt;personGrp&gt; deve avere @xml:id.
      </sch:assert>
      <sch:report test="@xml:id and string-length(@xml:id) &lt; 4"
                  role="warning">[PERSONGRP_ID_TOO_SHORT] 
        xml:id="<sch:value-of select="@xml:id"/>" sembra un'abbreviazione. Convenzione: snake_case descrittivo (es. coro_di_zingani anziché zin).
      </sch:report>
    </sch:rule>

    <sch:rule context="tei:surface">
      <sch:assert test="@xml:id" role="error">[SURFACE_NO_ID] 
        &lt;surface&gt; deve avere @xml:id (riferimenti @facs dipendono).
      </sch:assert>
    </sch:rule>

  </sch:pattern>

  <!-- ═══════════════════════════════════════════════════════════
       PATTERN 3 — Required structure
       ═══════════════════════════════════════════════════════════ -->
  <sch:pattern id="required-structure">

    <sch:rule context="tei:div3">
      <sch:assert test="@type" role="error">[DIV3_NO_TYPE] 
        &lt;div3&gt; deve avere @type. (La validazione del valore avviene in Python.)
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:sp">
      <sch:assert test="@who or tei:speaker"
                  role="error">[SP_NO_SPEAKER] 
        &lt;sp&gt; deve avere @who oppure &lt;speaker&gt;.
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:metDecl">
      <sch:assert test="@xml:id" role="error">[METDECL_NO_ID] 
        &lt;metDecl&gt; deve avere @xml:id.
      </sch:assert>
      <sch:assert test="tei:p[normalize-space(.)]"
                  role="error">[METDECL_NO_P] 
        &lt;metDecl&gt; deve contenere &lt;p&gt; con il nome del metro (es. "endecasillabo piano").
      </sch:assert>
    </sch:rule>

  </sch:pattern>

  <!-- ═══════════════════════════════════════════════════════════
       PATTERN 4 — Cross-reference syntactic check
       (Resolution + fuzzy suggestions handled in Python)
       ═══════════════════════════════════════════════════════════ -->
  <sch:pattern id="references-syntax">

    <sch:rule context="tei:persName[@ref]">
      <sch:assert test="starts-with(@ref, '#') or starts-with(@ref, 'http')"
                  role="error">[REF_NO_HASH] 
        @ref="<sch:value-of select="@ref"/>" deve iniziare con '#' (riferimento interno) o con un URI assoluto.
      </sch:assert>
    </sch:rule>

    <sch:rule context="tei:placeName[@ref]">
      <sch:assert test="starts-with(@ref, '#') or starts-with(@ref, 'http')"
                  role="error">[REF_NO_HASH] 
        @ref="<sch:value-of select="@ref"/>" deve iniziare con '#' o con un URI assoluto.
      </sch:assert>
    </sch:rule>

  </sch:pattern>

  <!-- ═══════════════════════════════════════════════════════════
       PATTERN 5 — Empty type values
       ═══════════════════════════════════════════════════════════ -->
  <sch:pattern id="empty-type">

    <sch:rule context="tei:stage[@type='']">
      <sch:report test="true()" role="warning">[EMPTY_TYPE_STAGE] 
        @type="" (vuoto) su &lt;stage&gt;. Rimuovere o specificare un valore.
      </sch:report>
    </sch:rule>

  </sch:pattern>

  <!-- ═══════════════════════════════════════════════════════════
       PATTERN 6 — Aside chain integrity (Option B)
       Per the 2026-05-18 editorial decision (Borin et al.), multi-line
       asides are encoded as a chain of inline <said>/<q>/<foreign>
       fragments stitched via xml:id + @prev + @next. Standoff
       <anchor>+<span> markup was retired by scripts/convert_anchor_to_chain.py.
       ═══════════════════════════════════════════════════════════ -->
  <sch:pattern id="aside-chain-integrity">

    <sch:rule context="tei:anchor">
      <sch:report test="true()" role="warning">[STANDOFF_ANCHOR]
        &lt;anchor&gt; reappeared. After 2026-05-18 the corpus uses chained
        inline &lt;said&gt;/&lt;q&gt;/&lt;foreign&gt; (Option B); standoff
        &lt;anchor&gt;+&lt;span&gt; markup is no longer in use. If this is
        a legitimate non-standoff anchor, suppress with an inline comment.
      </sch:report>
    </sch:rule>

    <sch:rule context="tei:span[@from or @to]">
      <sch:report test="true()" role="warning">[STANDOFF_SPAN]
        Standoff &lt;span from/to&gt; reappeared. The aside-marking pattern
        was retired on 2026-05-18 in favour of chained inline
        &lt;said&gt;/&lt;q&gt;/&lt;foreign&gt; (Option B).
      </sch:report>
    </sch:rule>

    <sch:rule context="tei:said[@prev or @next] | tei:q[@prev or @next] | tei:foreign[@prev or @next]">
      <sch:assert test="@xml:id" role="error">[CHAIN_NO_ID]
        Fragment with @prev or @next must also carry @xml:id; otherwise
        the chain cannot be addressed by another fragment.
      </sch:assert>
      <sch:assert test="not(@prev) or count(//*[@xml:id = substring-after(current()/@prev, '#')]) = 1"
                  role="error">[CHAIN_BROKEN_PREV]
        @prev="<sch:value-of select="@prev"/>" does not resolve to a
        fragment with that @xml:id. The chain is broken.
      </sch:assert>
      <sch:assert test="not(@next) or count(//*[@xml:id = substring-after(current()/@next, '#')]) = 1"
                  role="error">[CHAIN_BROKEN_NEXT]
        @next="<sch:value-of select="@next"/>" does not resolve to a
        fragment with that @xml:id. The chain is broken.
      </sch:assert>
    </sch:rule>

  </sch:pattern>

  <!-- ═══════════════════════════════════════════════════════════
       PATTERN 7 — Informational notices
       ═══════════════════════════════════════════════════════════ -->
  <sch:pattern id="info-notices">

    <sch:rule context="tei:teiHeader/tei:encodingDesc">
      <sch:report test="not(tei:metDecl)" role="info">[NO_METDECL] 
        Nessun &lt;metDecl&gt; — la vista di lettura non mostrerà annotazioni metriche. Atteso per Tier B (trascrizioni automatiche).
      </sch:report>
    </sch:rule>

    <sch:rule context="tei:resp">
      <sch:report test="normalize-space(.) = 'encoding'"
                  role="info">[RESP_ENGLISH_encoding] 
        &lt;resp&gt;encoding&lt;/resp&gt; in inglese; convenzione del progetto: italiano ("codifica").
      </sch:report>
      <sch:report test="normalize-space(.) = 'editing'"
                  role="info">[RESP_ENGLISH_editing] 
        &lt;resp&gt;editing&lt;/resp&gt; in inglese; convenzione: italiano ("edizione").
      </sch:report>
      <sch:report test="normalize-space(.) = 'transcription'"
                  role="info">[RESP_ENGLISH_transcription] 
        &lt;resp&gt;transcription&lt;/resp&gt; in inglese; convenzione: italiano ("trascrizione").
      </sch:report>
    </sch:rule>

  </sch:pattern>

</sch:schema>
