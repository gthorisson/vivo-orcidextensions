<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for document individuals -->

<#include "individual-setup.ftl">


<section id="individual-intro" class="" role="region">


        <header>
                <h1 class="fn bibo-document">
                    <#-- Label -->
                    <@p.label individual editable />
                        
                </h1>

            <#-- Authors -->
            <#assign authors = propertyGroups.getProperty("${core}informationResourceInAuthorship")!>
            <#if authors?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->

            <style type="text/css">
ul.flatlist
{
  display:inline;
  list-style-type:none;
  padding:0px;
  margin:0px;
}
ul.flatlist li
{
  display: inline;
}
ul.flatlist li:after
{
  content: " ";
}
ul.flatlist li.last:after
{
  content: " ";
}


</style>
            
               by: 
               <ul class="flatlist">
                 <@p.objectProperty authors false />
               </ul>
            </#if> 

            <#-- Rest of bibliographic info -->
            <#assign bibo = "http://purl.org/ontology/bibo/"!>
            
            <#assign pubVenue = propertyGroups.getProperty("${core}hasPublicationVenue")!>
            <#assign volume = propertyGroups.getProperty("${bibo}volume")!>
            <#assign issue = propertyGroups.getProperty("${bibo}issue")!>
            <#assign pageStart = propertyGroups.getProperty("${bibo}pageStart")!>
            <#assign pageEnd = propertyGroups.getProperty("${bibo}pageEnd")!>
            <#assign doi = propertyGroups.getProperty("${bibo}doi")!>
            <#assign dateTimeValue = propertyGroups.getProperty("${core}dateTimeValue")!>
            
              <br />Published in: 
              <#if pubVenue?has_content>
                <ul class="flatlist">
                  <@p.objectProperty  pubVenue false />
                </ul>
              </#if>
              <#if (volume?has_content && volume.statements?size != 0)>
                  Vol. <b>${volume.statements[0].value}</b>
              </#if>           
              <#if (issue?has_content && issue.statements?size != 0)>
                  No. ${issue.statements[0].value}
              </#if>           
              <#if (pageStart?has_content && pageStart.statements?size != 0)>
                  pp. ${pageStart.statements[0].value}
              </#if>           
              <#if (pageEnd?has_content && pageEnd.statements?size != 0)>
                  - ${pageEnd.statements[0].value}
              </#if>           
              <#if (doi?has_content && doi.statements?size != 0)>
                  doi:<a href="http://dx.doi.org/${doi.statements[0].value}">${doi.statements[0].value}</a>
              </#if>           
            
               
        </header>

        <nav role="navigation">
            <ul id ="individual-tools" role="list">
                <li role="listitem"><img title="${individual.uri}" class="middle" src="${urls.images}/individual/uriIcon.gif" alt="uri icon" /></li>
    
                <#assign rdfUrl = individual.rdfUrl>
                <#if rdfUrl??>
                    <li role="listitem"><a title="View this individual in RDF format" class="icon-rdf" href="${rdfUrl}">RDF</a></li>
                </#if>
            </ul>
        </nav>
        

</section>



<#-- Property group menu -->
<#include "individual-propertyGroupMenu.ftl">

<#-- Ontology properties -->
<#include "individual-properties.ftl">


${stylesheets.add("/css/individual/individual.css")}
${stylesheets.add("/css/individual/individual-vivo.css")}
                           
<#-- RY Figure out which of these scripts really need to go into the head, and which are needed at all (e.g., tinyMCE??) -->
${headScripts.add("/js/jquery_plugins/getURLParam.js",                  
                  "/js/jquery_plugins/colorAnimations.js",
                  "/js/jquery_plugins/jquery.form.js",
                  "/js/tiny_mce/tiny_mce.js", 
                  "/js/controls.js",
                  "/js/toggle.js",
                  "/js/jquery_plugins/jquery.truncator.js")}
                  
${scripts.add("/js/imageUpload/imageUploadUtils.js")}
${scripts.add("/js/individual/individualUtils.js")}