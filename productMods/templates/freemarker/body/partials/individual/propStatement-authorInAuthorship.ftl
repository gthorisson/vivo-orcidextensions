<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Custom object property statement view for http://vivoweb.org/ontology/core#authorInAuthorship -->

<#import "lib-sequence.ftl" as s>
<#import "lib-datetime.ftl" as dt>

<@showAuthorship statement />

<#-- Use a macro to keep variable assignments local; otherwise the values carry over to the
     next statement -->
<#macro showAuthorship statement>

    <#local linkedIndividual>
        <#if statement.infoResource??>
            <a href="${profileUrl(statement.infoResource)}">${statement.infoResourceName}</a>        
        <#else>
            <#-- This shouldn't happen, but we must provide for it -->
            <a href="${profileUrl(statement.authorship)}">missing information resource</a>
        </#if>     
    </#local>

   ${linkedIndividual}

    <#if statement.publicationVenue??>
      in <i>${statement.publicationVenueName}</i>
    </#if>

    <#if statement.volume??>
       Vol. <b>${statement.volume}</b>
    </#if>

    <#if statement.issue??>
      No. ${statement.issue}
    </#if>
    
    <#if statement.dateTime??>        
     (<@dt.yearSpan "${statement.dateTime!}" />)
    </#if>
    

    <#if statement.doi??>
    doi:<a href="http://dx.doi.org/${statement.doi}">${statement.doi}</a>
    </#if>
                        
        

</#macro>