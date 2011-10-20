<%--
Copyright (c) 2011, Cornell University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of Cornell University nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--%>

<%-- Custom form for adding a publication to an author

Classes: 
foaf:Person - the individual being edited
core:Authorship - primary new individual being created

Object properties (domain : range):

core:authorInAuthorship (Person : Authorship) 
core:linkedAuthor (Authorship : Person) - inverse of authorInAuthorship

core:linkedInformationResource (Authorship : InformationResource) 
core:informationResourceInAuthorship (InformationResource : Authorship) - inverse of linkedInformationResource

--%>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>

<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.hp.hpl.jena.vocabulary.XSD" %>

<%@page import="edu.cornell.mannlib.vitro.webapp.beans.ObjectPropertyStatement"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.VitroVocabulary" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.configuration.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.PersonHasPublicationValidator" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.freemarker.UrlBuilder.JavaScript" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.freemarker.UrlBuilder.Css" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.utils.FrontEndEditingUtils"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.utils.FrontEndEditingUtils.EditMode"%>

<%@ page import="org.apache.commons.logging.Log" %>
<%@ page import="org.apache.commons.logging.LogFactory" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core"%>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>

<%! 
    public static Log log = LogFactory.getLog("edu.cornell.mannlib.vitro.webapp.jsp.edit.forms.addAuthorsToInformationResource.jsp");
    public static String nodeToPubProp = "http://vivoweb.org/ontology/core#linkedInformationResource";
%>
<%

    VitroRequest vreq = new VitroRequest(request);

    String subjectUri = vreq.getParameter("subjectUri");
    String predicateUri = vreq.getParameter("predicateUri");
    String objectUri = vreq.getParameter("objectUri");

	Individual obj = (Individual) request.getAttribute("object");

    EditMode mode = FrontEndEditingUtils.getEditMode(request, nodeToPubProp);

    /*
    There are 3 modes that this form can be in: 
     1.  Add. There is a subject and a predicate but no position and nothing else. 
     
     2. Repair a bad role node.  There is a subject, predicate and object but there is no individual on the 
        other end of the object's core:linkedInformationResource stmt.  This should be similar to an add but the form should be expanded.
        
     3. Really bad node. Multiple core:authorInAuthorship statements.   
     
     This form does not currently support normal edit mode where there is a subject, an object, and an individual on
     the other end of the object's core:linkedInformationResource statement. We redirect to the publication profile
     to edit the publication.
    */
    
    if( mode == EditMode.ADD ) {
       %> <c:set var="editMode" value="add"/><%
    } else if(mode == EditMode.EDIT){
        // Because it's edit mode, we already know there's one and only one statement
        ObjectPropertyStatement ops = obj.getObjectPropertyStatements(nodeToPubProp).get(0);
        String pubUri = ops.getObjectURI();
        String forwardToIndividual = pubUri != null ? pubUri : objectUri;         
        %>  
        <jsp:forward page="/individual">
            <jsp:param value="<%= forwardToIndividual %>" name="uri"/>
        </jsp:forward>  
        <%              
    } else if(mode == EditMode.REPAIR){
        %> <c:set var="editMode" value="repair"/><%
    }
    
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();    
    vreq.setAttribute("defaultNamespace", ""); //empty string triggers default new URI behavior
    
    Individual subject = (Individual) request.getAttribute("subject");
    String subjectName = subject.getName();
    vreq.setAttribute("subjectUriJson", MiscWebUtils.escape(subjectUri));
    
    vreq.setAttribute("stringDatatypeUriJson", MiscWebUtils.escape(XSD.xstring.toString()));
    
    String intDatatypeUri = XSD.xint.toString();    
    vreq.setAttribute("intDatatypeUri", intDatatypeUri);
    vreq.setAttribute("intDatatypeUriJson", MiscWebUtils.escape(intDatatypeUri));

%>

<c:set var="vivoOnt" value="http://vivoweb.org/ontology" />
<c:set var="vivoCore" value="${vivoOnt}/core#" />
<c:set var="rdfs" value="<%= VitroVocabulary.RDFS %>" />
<c:set var="label" value="${rdfs}label" />
<c:set var="infoResourceClassUri" value="${vivoCore}InformationResource" />
<c:set var="bibo" value="http://purl.org/ontology/bibo/" />
<c:set var="dc" value="http://purl.org/dc/terms/" />

<%-- Unlike other custom forms, this form does not allow edits of existing authors, so there are no
SPARQL queries for existing values. --%>

<v:jsonset var="newPubTypeAssertion">
    ?pubUri a ?pubType .    
</v:jsonset>

<v:jsonset var="newPubNameAssertion">
    ?pubUri <${label}> ?title .   
</v:jsonset>

<%-- one of several additional bibinfo triples, which should feed into the newly-created pub record.  --%>
<v:jsonset var="newPubVolumeAssertion">
     ?pubUri <${bibo}volume> ?pubVolume .
</v:jsonset>
<v:jsonset var="newPubIssueAssertion">
     ?pubUri <${bibo}issue> ?pubIssue .
</v:jsonset>
<v:jsonset var="newPubPageStartAssertion">
     ?pubUri <${bibo}pageStart> ?pubPageStart .
</v:jsonset>
<v:jsonset var="newPubPageEndAssertion">
     ?pubUri <${bibo}pageEnd> ?pubPageEnd .
</v:jsonset>
<v:jsonset var="newPubDOIAssertion">
     ?pubUri <${bibo}doi> ?pubDOI .
</v:jsonset>
<v:jsonset var="newPubDateTimeAssertion">
     ?pubUri <${vivoCore}dateTimeValue> ?pubDateTimeUri .
</v:jsonset>



<%-- This applies to both a new and an existing publication --%>
<v:jsonset var="n3ForNewAuthorship">
    @prefix core: <${vivoCore}> .
    @prefix bibo: <${bibo}> .
    
    ?authorshipUri a core:Authorship ;
                   core:linkedAuthor ?person .  
                     
    ?person core:authorInAuthorship ?authorshipUri .                
</v:jsonset>

<v:jsonset var="n3ForExistingPub">
    @prefix core: <${vivoCore}> .
    @prefix bibo: <${bibo}> .
        
    ?authorshipUri core:linkedInformationResource ?pubUri .
    ?pubUri core:informationResourceInAuthorship ?authorshipUri .
</v:jsonset>

<v:jsonset var="n3ForNewPub">
    @prefix core: <${vivoCore}> .
    @prefix bibo: <${bibo}> .
    
    ?pubUri a ?pubType ;
            <${label}> ?title .
               
    ?authorshipUri core:linkedInformationResource ?pubUri .
    ?pubUri core:informationResourceInAuthorship ?authorshipUri .               
</v:jsonset>

<!-- Creating a new datetime for the pub -->
<v:jsonset var="n3ForNewPubDateTime">
    @prefix core: <${vivoCore}> .
    @prefix bibo: <${bibo}> .
    @prefix rdfs: <${rdfs}> .
    
    ?pubDateTimeUri a core:DateTimeValue ;
                    <${vivoCore}dateTime> ?pubDateTime^^<http://www.w3.org/2001/XMLSchema#dateTime> ;
                    <${vivoCore}dateTimePrecision> ?pubDateTimePrecisionUri .
</v:jsonset>


<%-- Creating a new publication venue - aka journal--%>
<v:jsonset var="n3ForExistingVenue">
    @prefix core: <${vivoCore}> .
    @prefix bibo: <${bibo}> .
    @prefix rdfs: <${rdfs}> .

     ?venueUri a ?venueTypeUri ;
               <${label}> ?venueTitle .

     ?pubUri core:hasPublicationVenue ?venueUri .
     ?venueUri core:publicationVenueFor ?pubUri .
</v:jsonset>
<%-- May have additional assertions describing the venue --%>
<v:jsonset var="existingVenueISSNAssertion">
     ?venueUri <${bibo}issn> ?venueISSN .
</v:jsonset>




<c:set var="publicationTypeLiteralOptions">
    ["", "Select one"],
    ["http://purl.org/ontology/bibo/AcademicArticle", "Academic Article"],
    ["http://purl.org/ontology/bibo/Article", "Article"],
    ["http://purl.org/ontology/bibo/AudioDocument", "Audio Document"],
    ["http://vivoweb.org/ontology/core#BlogPosting", "Blog Posting"],
    ["http://purl.org/ontology/bibo/Book", "Book"],
    ["http://vivoweb.org/ontology/core#CaseStudy", "Case Study"],
    ["http://vivoweb.org/ontology/core#Catalog", "Catalog"],
    ["http://purl.org/ontology/bibo/Chapter", "Chapter"],
    ["http://vivoweb.org/ontology/core#ConferencePaper", "Conference Paper"],
    ["http://vivoweb.org/ontology/core#ConferencePoster", "Conference Poster"],
    ["http://vivoweb.org/ontology/core#Database", "Database"],
    ["http://purl.org/ontology/bibo/EditedBook", "Edited Book"],
    ["http://vivoweb.org/ontology/core#EditorialArticle", "Editorial Article"],
    ["http://purl.org/ontology/bibo/Film", "Film"],
    ["http://vivoweb.org/ontology/core#Newsletter", "Newsletter"],
    ["http://vivoweb.org/ontology/core#NewsRelease", "News Release"],
    ["http://purl.org/ontology/bibo/Patent", "Patent"],
    ["http://purl.obolibrary.org/obo/OBI_0000272", "Protocol"],
    ["http://purl.org/ontology/bibo/Report", "Report"],
    ["http://vivoweb.org/ontology/core#ResearchProposal", "Research Proposal"],
    ["http://vivoweb.org/ontology/core#Review", "Review"],
    ["http://vivoweb.org/ontology/core#Software", "Software"],
    ["http://vivoweb.org/ontology/core#Speech", "Speech"],
    ["http://purl.org/ontology/bibo/Thesis", "Thesis"],
    ["http://vivoweb.org/ontology/core#Video", "Video"],
    ["http://purl.org/ontology/bibo/Webpage", "Webpage"],
    ["http://purl.org/ontology/bibo/Website", "Website"],
    ["http://vivoweb.org/ontology/core#WorkingPaper", "Working Paper"]
</c:set>

<c:set var="editjson" scope="request">
{
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",
    "urlPatternToReturnTo" : "/individual",

    "subject"   : ["person", "${subjectUriJson}" ],
    "predicate" : ["predicate", "${predicateUriJson}" ],
    "object"    : ["authorshipUri", "${objectUriJson}", "URI" ],
    
    "n3required"    : [ "${n3ForNewAuthorship}" ],

    "n3optional"    : [ "${n3ForExistingPub}", "${n3ForNewPub}", "${n3ForExistingVenue}",
                        "${newPubNameAssertion}", "${newPubTypeAssertion}",
                        "${n3ForNewPubDateTime}","${newPubDateTimeAssertion}","${newPubVolumeAssertion}",
                        "${newPubIssueAssertion}", "${newPubPageStartAssertion}",
                        "${newPubPageEndAssertion}", "${newPubDOIAssertion}","$existingVenueISSNAssertion" ],        

    "newResources"  : { "authorshipUri" : "${defaultNamespace}",
                        "pubUri" : "${defaultNamespace}",
                        "pubDateTimeUri" : "${defaultNamespace}" },
                                                                                        

    "urisInScope"    : { },
    "literalsInScope": { },
    "urisOnForm"     : [ "pubUri", "pubType", "pubDateTimeUri", "pubDateTimePrecisionUri", "venueUri","venueTypeUri" ],
    "literalsOnForm" : [ "title", "pubDateTime", "pubVolume","pubIssue","pubPageStart","pubPageEnd","pubDOI","venueTitle","venueISSN" ],
    "filesOnForm"    : [ ],
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : { },
    "sparqlForExistingUris" : { },
    "fields" : {
      "title" : {
         "newResource"      : "false",
         "validators"       : [ "datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${n3ForNewPub}" ]
      },   

      "pubDateTime" : {
         "newResource"      : "false",
         "validators"       : [ "datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${n3ForNewPubDateTime}" ]
      },      
      "pubVolume" : {
         "newResource"      : "false",
         "validators"       : [ "datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${newPubVolumeAssertion}" ]
      },      
      "pubIssue" : {
         "newResource"      : "false",
         "validators"       : [ "datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${newPubIssueAssertion}" ]
      },      
      "pubPageStart" : {
         "newResource"      : "false",
         "validators"       : [ "datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${newPubPageStartAssertion}" ]
      },      
      "pubPageEnd" : {
         "newResource"      : "false",
         "validators"       : [ "datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${newPubPageEndAssertion}" ]
      },      
      "pubDOI" : {
         "newResource"      : "false",
         "validators"       : [ "datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${newPubDOIAssertion}" ]
      }, 
      "pubType" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "HARDCODED_LITERALS",
         "literalOptions"   : [ ${publicationTypeLiteralOptions} ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${newPubTypeAssertion}" ]
      },               
      "pubUri" : {
         "newResource"      : "true",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "${personClassUriJson}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",         
         "assertions"       : ["${n3ForExistingPub}"]
      },
            "pubDateTimeUri" : {
         "newResource"      : "true",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "${personClassUriJson}",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",         
         "assertions"       : ["${newPubDateTimeAssertion}", "${n3ForNewPubDateTime}" ]
      },
      "venueUri" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "",
         "rangeLang"        : "",
         "assertions"       : [ "${n3ForExistingVenue}" ]
      },            
      "venueTitle" : {
         "newResource"      : "false",
         "validators"       : ["datatype:${stringDatatypeUriJson}"  ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${n3ForExistingVenue}" ]
      },      
      "venueISSN" : {
         "newResource"      : "false",
         "validators"       : ["datatype:${stringDatatypeUriJson}" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [ ],
         "predicateUri"     : "",
         "objectClassUri"   : "",
         "rangeDatatypeUri" : "${stringDatatypeUriJson}",
         "rangeLang"        : "",
         "assertions"       : [ "${existingVenueISSNAssertion}" ]
      },    
  }
}
</c:set>
   
<%
    log.debug(request.getAttribute("editjson"));

    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    if (editConfig == null) {
        editConfig = new EditConfiguration((String) request.getAttribute("editjson"));     
        EditConfiguration.putConfigInSession(editConfig,session);
    }
    
    editConfig.addValidator(new PersonHasPublicationValidator());
    
    Model model = (Model) application.getAttribute("jenaOntModel");
    
    if (objectUri != null) { // editing existing (in this case, only repair is currently provided by the form)
        editConfig.prepareForObjPropUpdate(model);
    } else { // adding new
        editConfig.prepareForNonUpdate(model);
    }
    
    // Return to person, not publication. See NIHVIVO-1464.
  	// editConfig.setEntityToReturnTo("?pubUri"); 
    
    List<String> customJs = new ArrayList<String>(Arrays.asList(JavaScript.JQUERY_UI.path(),
                                                                JavaScript.CUSTOM_FORM_UTILS.path(),
                                                                "/js/browserUtils.js",
                                                                "/edit/forms/js/customFormWithAutocomplete.js",
                                                                "/edit/forms/js/addPublicationInExternalSystem.js",
                                                                "/js/jquery_plugins/jquery.rdfquery.core-1.0.js",
                                                                "/js/jquery_plugins/jquery.dataTables.min.js"
                                                                
                                                               ));            
    request.setAttribute("customJs", customJs);
    
    List<String> customCss = new ArrayList<String>(Arrays.asList(Css.JQUERY_UI.path(),
                                                                 Css.CUSTOM_FORM.path(),
                                                                 "/edit/forms/css/customFormWithAutocomplete.css",
                                                                 "/css/jquery_plugins/demo_table.css"
                                                                 ));                                                                                                                                   
    request.setAttribute("customCss", customCss); 
%>

<%-- Configure add vs. edit --%> 
<c:choose>
    <c:when test='${editMode == "add"}'>
        <c:set var="titleVerb" value="Create" />
        <c:set var="submitButtonText" value="Publication" />
    </c:when>
    <c:otherwise>
        <c:set var="titleVerb" value="Edit" />  
        <c:set var="submitButtonText" value="Edit Publication" />
    </c:otherwise>
</c:choose>

<c:set var="requiredHint" value="<span class='requiredHint'> *</span>" />

<jsp:include page="${preForm}" />

<% if( mode == EditMode.ERROR ){ %>
 <div>This form is unable to handle the editing of this position because it is associated with 
      multiple Position individuals.</div>      
<% }else{ %>

<h2>${titleVerb} publication entry for <%= subjectName %></h2>

<%@ include file="unsupportedBrowserMessage.jsp" %>

<%-- DO NOT CHANGE IDS, CLASSES, OR HTML STRUCTURE IN THIS FORM WITHOUT UNDERSTANDING THE IMPACT ON THE JAVASCRIPT! --%>
<form id="addPublicationForm" class="customForm noIE67"  action="<c:url value="/edit/processRdfForm2.jsp"/>" >

    <p class="inline"><v:input type="select" label="Publication Type ${requiredHint}" name="pubType" id="typeSelector" /></p>

    <div class="fullViewOnly">


       <h3>Look up publication in VIVO by title, or create a new publication from scratch</h3>
        
  	   <p><v:input type="text" id="relatedIndLabel" name="title" label="Title ${requiredHint}" cssClass="acSelector" size="50" /></p>

	    <div class="acSelection">
	        <%-- RY maybe make this a label and input field. See what looks best. --%>
	        <p class="inline"><label></label><span class="acSelectionInfo"></span> <a href="<c:url value="/individual?uri=" />" class="verifyMatch">(Verify this match)</a></p>
	        <input type="hidden" id="pubUri" name="pubUri" class="acUriReceiver" value="" /> <!-- Field value populated by JavaScript -->
	    </div>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>OR</b>

       <h3>Search for existing publication in CrossRef</h3>
	    <!--  [perhaps hide this and only reveal if user clicks link or button]  -->

	    <!-- add selector for CrossRef / PubMed / IEEE etc. - how to make this configurable?? -->	           
        <!-- figure out how to only show this IF its an article?
          more generally: IF article THEN show CrossRef / Pubmed / etc options
                          IF dataset THEN show DataCite
                          etc.          
          -->

	  <p>
	    <v:input type="text" id="externalPubLookupTerms" name="externalPubLookupTerms" label="Enter search terms" size="50" />	    

        <a href="#" id="externalPubLookupSubmit"> <img src="http://images.orcidsandbox.org/WOK46/images/RID/search.gif" alt="Search" title="Search" /></a>
      </p>
      
      <div id="externalPubLookupStatus" align="left" style="display:none;">
        <!-- <img src="http://images.orcidsandbox.org/WOK46/images/RID/working.gif" alt="working" title="working" />-->
        <img src="/images/visualization/ajax-loader-indicator.gif" alt="working" title="working" />
        <span></span>
      </div>
            
      <div class="externalPubLookupListing" id="externalPubLookupResultListing"></div>
      
      <pre id="externalPubLookupDetailsTriples" style="display: block">
      
      </pre>
      <div id="externalPubLookupDetails" style="display: none">
      <p><b>Details for selected publication:</b></p>

	    <input type="hidden" id="venueUri" name="venueUri" label="Journal URI" size="30" />	    
	    <v:input type="text" id="venueTitle" name="venueTitle" label="Published in" size="30" />	    
	    ISSN: <input type="text" id="venueISSN" name="venueISSN" label="ISSN" size="30" />	    
	    <input type="hidden" id="venueTypeUri" name="venueTypeUri" label="Journal type URI" size="30" />	    
      
	    <v:input type="text" id="pubDateTime" name="pubDateTime" label="Date published" size="30" />
        <input type="hidden" id="pubDateTimeUri" name="pubDateTimeUri" value="" />
	    <input type="hidden" id="pubDateTimePrecisionUri" name="pubDateTimePrecisionUri" label="Datetime precision" size="30" />
	    <v:input type="text" id="pubVolume" name="pubVolume" label="Volume" size="30" />	    
	    <v:input type="text" id="pubIssue" name="pubIssue" label="Issue" size="30" />	    
	    <v:input type="text" id="pubPageStart" name="pubPageStart" label="Page start" size="30" />	    
	    <v:input type="text" id="pubPageEnd" name="pubPageEnd" label="Page end" size="30" />	    
	    <v:input type="text" id="pubDOI" name="pubDOI" label="DOI" size="50" />
	    <!-- ? generate author fields dynamically ? OR just print multiple lines to textarea, a la CiteULike..  -->


      <p><b>Authors:</b></p>
 [...]
      </div>
 
	    
    </div>
    
    <p class="submit"><v:input type="submit" id="submit" value="Publication" cancel="true" /></p>
    
    
    <p id="requiredLegend" class="requiredHint">* required fields</p>
</form>

<c:url var="acUrl" value="/autocomplete?tokenize=true" />
<c:url var="sparqlQueryUrl" value="/ajax/sparqlQuery" />
<c:url var="externalLookupUrl" value="/railsext/biblio/search" />

<%-- Must be all one line for JavaScript. --%>
<c:set var="sparqlForAcFilter">
PREFIX core: <${vivoCore}> SELECT ?pubUri WHERE {<${subjectUri}> core:authorInAuthorship ?authorshipUri . ?authorshipUri core:linkedInformationResource ?pubUri .}
</c:set>

<script type="text/javascript">
var customFormData  = {
    sparqlForAcFilter: '${sparqlForAcFilter}',
    sparqlQueryUrl: '${sparqlQueryUrl}',
    acUrl: '${acUrl}',
    submitButtonTextType: 'simple',
    editMode: '${editMode}',
    defaultTypeName: 'publication' // used in repair mode to generate button text
};
</script>

<% } %>

<jsp:include page="${postForm}"/>