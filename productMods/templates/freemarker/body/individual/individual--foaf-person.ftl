<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Person individuals -->

<#include "individual-setup.ftl">
    
<section id="individual-intro" class="vcard person" role="region">
    <section id="share-contact" role="region"> 
        <#-- Image -->           
        <#assign individualImage>
            <@p.image individual=individual 
                      propertyGroups=propertyGroups 
                      namespaces=namespaces 
                      editable=editable 
                      showPlaceholder="always" 
                      placeholder="${urls.images}/placeholders/person.thumbnail.jpg" />
        </#assign>

        <#if ( individualImage?contains('<img class="individual-photo"') )>
            <#assign infoClass = 'class="withThumb"'/>
        </#if>

        <div id="photo-wrapper">${individualImage}</div>
    
        <nav role="navigation">
            <ul id ="individual-tools-people" role="list">
                <li role="listitem"><img title="${individual.uri}" class="middle" src="${urls.images}/individual/uriIcon.gif" alt="uri icon" /></li>
    
                <#assign rdfUrl = individual.rdfUrl>
                <#if rdfUrl??>
                    <li role="listitem"><a title="View this individual in RDF format" class="icon-rdf" href="${rdfUrl}">RDF</a></li>
                </#if>
            </ul>
        </nav>
            
        <#-- Email -->    
        <#assign email = propertyGroups.getPropertyAndRemoveFromList("${core}email")!>      
        <#if email?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
            <@p.addLinkWithLabel email editable />
            <#if email.statements?has_content> <#-- if there are any statements -->
                <ul id="individual-email" role="list">
                    <#list email.statements as statement>
                        <li role="listitem">
                            <img class ="icon-email middle" src="${urls.images}/individual/emailIcon.gif" alt="email icon" /><a class="email" href="mailto:${statement.value}">${statement.value}</a>
                            <@p.editingLinks "${email.localName}" statement editable />
                        </li>
                    </#list>
                </ul>
            </#if>
        </#if>
          
        <#-- Phone --> 
        <#assign phone = propertyGroups.getPropertyAndRemoveFromList("${core}phoneNumber")!>
        <#if phone?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
            <@p.addLinkWithLabel phone editable />
            <#if phone.statements?has_content> <#-- if there are any statements -->
                <ul id="individual-phone" role="list">
                    <#list phone.statements as statement>
                        <li role="listitem">                           
                           <img class ="icon-phone  middle" src="${urls.images}/individual/phoneIcon.gif" alt="phone icon" />${statement.value}
                            <@p.editingLinks "${phone.localName}" statement editable />
                        </li>
                    </#list>
                </ul>
            </#if>
        </#if>      
                
        <#-- Links -->  
        <@p.vitroLinks propertyGroups namespaces editable "individual-urls-people" />
    </section>

    <section id="individual-info" ${infoClass!} role="region">
        <#include "individual-visualizationFoafPerson.ftl">    
        <#-- Disable for now until controller sends data -->
        <#--
        <section id="co-authors" role="region">
            <header>
                <h3><span class="grey">10 </span>Co-Authors</h3>
            </header>

            <ul role="list">
                <li role="listitem"><a href="#"><img class="co-author" src="" /></a></li>
                <li role="listitem"><a href="#"><img class="co-author" src="" /></a></li>
            </ul>

            <p class="view-all-coauthors"><a class="view-all-style" href="#">View All <img src="${urls.images}/arrowIcon.gif" alt="arrow icon" /></a></p>
        </section>
        -->
        
        <#if individual.showAdminPanel>
            <#include "individual-adminPanel.ftl">
        </#if>
        
        <header>
            <#if relatedSubject??>
                <h2>${relatedSubject.relatingPredicateDomainPublic} for ${relatedSubject.name}</h2>
                <p><a href="${relatedSubject.url}">&larr; return to ${relatedSubject.name}</a></p>
            <#else>                
                <h1 class="fn foaf-person">
                    <#-- Label -->
                    <@p.label individual editable />
                        
                    <#-- Moniker / Preferred Title -->
                    <#-- Use Preferred Title over Moniker if it is populated -->
                    <#assign title = (propertyGroups.getProperty("${core}preferredTitle").firstValue)! />
                    <#if ! title?has_content>
                        <#assign title = individual.moniker>
                    </#if>
                    <#if title?has_content>
                        <span class="preferred-title">${title}</span>
                    </#if>
                </h1>
            </#if>
               
            <#-- Positions -->
            <#assign positions = propertyGroups.getPropertyAndRemoveFromList("${core}personInPosition")!>
            <#if positions?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
                <@p.objectPropertyListing positions editable />
            </#if> 
        </header>
         
        <#-- Overview -->
        <#include "individual-overview.ftl">
        
        <#-- Research Areas -->
        <#assign researchAreas = propertyGroups.getPropertyAndRemoveFromList("${core}hasResearchArea")!> 
        <#if researchAreas?has_content> <#-- true when the property is in the list, even if not populated (when editing) -->
            <@p.objectPropertyListing researchAreas editable />
        </#if>   
    </section>
    
</section>


<!--    

<section>

<#if editable>    

<h2>Add publications</h2>
   
            <table border="0" cellspacing="0" cellpadding="10" style="width: 600px;">
             <tbody>
              <tr>
                <td valign="top" style="border-style: dashed;">
                  <img src="http://images.orcidsandbox.org/WOK46/images/RID/addDOIlogo.gif" alt="Digital Object Identifier logo" title="Digital Object Identifier logo" width="253" height="28"/>
                  <div class="addBox">
                    <dl>
                      <dt>                          
                        <form action="/jruby/bibliosearch" method="GET" accept-charset="utf-8">                                 
                          DOI search:<input type="text" size="25" name="query" value="${individual.nameStatement.value}"/> <input type="submit" value="Submit" />                                     
                        </form>                      
                      </dt>
                    </dl>	                  
                  </div>
                </td>
                <td valign="top" style="border-style: dashed;">
                  <img src="http://images.orcidsandbox.org/WOK46/images/RID/addRISlogo.gif" alt="Upload RIS File logo" title="Upload RIS File logo" width="253" height="28"/>
                  <div class="addBox">
                    <dl>
                      <dt>
                        <a href="#" style="color:middleblue;" onClick="document.forms['pubList'].action = 'ViewFileUpload.action';document.forms['pubList'].submit();return false;">Upload an RIS file (from EndNote, RefMan, or other reference software)</a>
                      </dt>
                   </dl>				  
                  </div>
                </td>
              </tr>
            </tbody>
            </table>
    
</section>

</#if>
-->


<#assign nameForOtherGroup = "other"> <#-- used by both individual-propertyGroupMenu.ftl and individual-properties.ftl -->

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