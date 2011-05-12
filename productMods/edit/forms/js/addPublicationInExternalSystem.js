
/*

[blurb about VIVO-ORCID collab project]

*/



// Set up Ajax request itself to be fired off when user clicks the Search button
$('#externalPubLookupSubmit').click( function(){ searchExternal() } );
// OR hits the Enter key
$('#externalPubLookupTerms').keypress(function(e) {	
	if(e.which ==13) {
	   e.preventDefault();
	   $('#externalPubLookupSubmit').click();
	}
});

//$('#externalPubLookupSubmit').click();
		
function searchExternal () {
      $('#externalPubLookupResultListing').empty(); // Remove any previous result listing
      $('#externalPubLookupDetails').hide(); // Hide external pub details, user had previously clicked on a result listing entry

      $('#externalPubLookupStatus > span').text('Searching CrossRef bibliographic metadata')
      $('#externalPubLookupStatus').show(); // Show progress indicator
      var queryString = $('#externalPubLookupTerms').val();
	  $.getJSON('/jruby/bibliosearch?',
	  {
		      query: queryString
	      },
          function(data) {
   	          $('#externalPubLookupStatus').hide(); // hide progress indicator
   	            
   	            var bibdata = []; // This will be populated in the callback and then fed to DataTable
	    	    $.each(data, function(i,item){
	    	    	bibdata.push([item.fullCitation,item.doi,null]);	    	    		    	        
	    	    });
	    	    
	    	    // ToDo: error handler, to catch 500 or other errors from external search service & display error msg to user
	    	    
   	            // Do DataTables magic and create table from data collected above
                $('#externalPubLookupResultListing').html( '<table cellpadding="0" cellspacing="0" border="0" class="display" id="externalPubTable"></table>' );
                var oTable =  $('#externalPubTable').dataTable({
     	        	"bFilter": false,
     	        	"bPaginate": false,
     	        	"bAutoWidth": true,
     	        	"aaData": bibdata,
     	        	"aoColumns": [
     	        	           { "sTitle": "Citation" },
     	        	           { "sTitle": "DOI raw","bVisible": false },
     	        	           { "sTitle": "DOI",
     	        	        	 // Special handling to display hyperlinked DOI name
     	        	        	 "fnRender": function(obj) {
     	      		    		     	var doi = obj.aData[1]; // grab raw DOI from other column
     	      			    	    	var doi_url = 'http://dx.doi.org/' + doi;
        	      		    		    var doi_formatted = 'doi:<a href="' + doi_url + '">' + doi + '</a>';        	      		    		    
        	      		    		    return doi_formatted; // This should be displayed in the table
     	   		            		}
     	        	       	   },
     	        	       	   ],
     	        	  "fnRowCallback": function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {
     	        	      	$(nRow).click( function() {
       	     	              var doi = aData[1];
     	 	    	          $('#externalPubLookupResultListing').empty(); // Remove result listing
     	 	    	          $('#externalPubLookupDetails').hide();
     	 	    	          $('#externalPubLookupStatus > span').text('Retrieving metadata for doi:'+doi)
     		    	          $('#externalPubLookupStatus').show(); // Show progress indicator again     		    	          

     		    	    	  // ? can we set the pubType dropdown based on pub type from RDF? 
     		    	    	  // retrieve & display full citation details as RDF
     		    	    	  $.get('/jruby/bibliofetch?doi=' + doi, function(bibdetails_rdf) {
     		    	    		  //alert("success in retrieving external bibdata for DOI " + doi);
     		    	   	          $('#externalPubLookupStatus').hide(); // hide progress indicator
     		    	   	               		    	    	  
     		    	    	      // Create a mini-triplestore from the RDF we just retrieved
     		    	    	 
         		    	    	  //    var rdf = $('#externalPubLookupDetailsTriples').rdf()
     		    	   	          //var databank = $.rdf.databank();
     			    	    	  var doi_url = 'http://dx.doi.org/' + doi;
     			    	    	  //bibdetails_rdf = '{"http://dx.doi.org/10.1016/0304-4149(85)90322-9":{"http://purl.org/dc/terms/identifier":[{"type":"literal","value":"10.1016/0304-4149(85)90322-9"}],"http://www.w3.org/2002/07/owl#sameAs":[{"type":"uri","value":"info:doi/10.1016/0304-4149(85)90322-9"},{"type":"uri","value":"doi:10.1016/0304-4149(85)90322-9"}],"http://prismstandard.org/namespaces/basic/2.1/doi":[{"type":"literal","value":"10.1016/0304-4149(85)90322-9"}],"http://purl.org/ontology/bibo/doi":[{"type":"literal","value":"10.1016/0304-4149(85)90322-9"}],"http://purl.org/dc/terms/date":[{"type":"literal","value":"1985"}],"http://purl.org/ontology/bibo/volume":[{"type":"literal","value":"21"}],"http://prismstandard.org/namespaces/basic/2.1/volume":[{"type":"literal","value":"21"}],"http://purl.org/ontology/bibo/pageStart":[{"type":"literal","value":"52"}],"http://prismstandard.org/namespaces/basic/2.1/startingPage":[{"type":"literal","value":"52"}],"http://purl.org/dc/terms/title":[{"type":"literal","value":"On maximal and distributional coupling  Hermann Thorisson, Chalmers University of Technology, Sweden"}],"http://purl.org/dc/terms/publisher":[{"type":"literal","value":"Elsevier BV"}],"http://www.w3.org/1999/02/22-rdf-syntax-ns#type":[{"type":"uri","value":"http://purl.org/ontology/bibo/Article"}],"http://purl.org/dc/terms/isPartOf":[{"type":"uri","value":"http://id.crossref.org/issn/0304-4149"}]},"http://id.crossref.org/issn/0304-4149":{"http://purl.org/dc/terms/title":[{"type":"literal","value":"Stochastic Processes and their Applications"}],"http://purl.org/ontology/bibo/issn":[{"type":"literal","value":"0304-4149"}],"http://prismstandard.org/namespaces/basic/2.1/issn":[{"type":"literal","value":"0304-4149"}],"http://purl.org/dc/terms/hasPart":[{"type":"uri","value":"http://dx.doi.org/10.1016/0304-4149(85)90322-9"}],"http://www.w3.org/1999/02/22-rdf-syntax-ns#type":[{"type":"uri","value":"http://purl.org/ontology/bibo/Journal"}],"http://www.w3.org/2002/07/owl#sameAs":[{"type":"uri","value":"urn:issn:0304-4149"}],"http://purl.org/dc/terms/identifier":[{"type":"literal","value":"0304-4149"}]}}';
     			    	    	  var rdf = $.rdf().load($.parseJSON(bibdetails_rdf));
     		    	    	       rdf.prefix('dc','http://purl.org/dc/terms/')
     		    	    	         .prefix('bibo','http://purl.org/ontology/bibo/')
     		    	    	         .prefix('prism','http://prismstandard.org/namespaces/basic/2.1/')
     		    	    	         .prefix('owl','http://www.w3.org/2002/07/owl#')
   		    	    	             .prefix('rdfs','http://www.w3.org/2000/01/rdf-schema#');

     		    	   	          //databank.load(bibdetails_rdf);
     		    	    	      //  	    .prefix('dc','http://purl.org/dc/terms/')
     		    	    	      //          .prefix('bibo','http://purl.org/ontology/bibo/')     		    	    	                   ;
     		    	    	      // .rdf().load(bibdata_full, {})
     		    	    	           		    	    		  

     		    	    	      // Extract the triples we want by querying the RDF object in hand
   		    	    	         
     		    	    	      // ?? could set the pubtype field - a subclass assertion
     		    	    	       
     		    	    	      // Literals
     		    	    	       
            	    	          // Set pub title field
     		    	    	      rdf.where('<' + doi_url + '> dc:title ?title')
     		    	    	         .each(function(index) {
     		    	    	            $('#relatedIndLabel').focus();
         		    	    	        $('#relatedIndLabel').val(this.title.value);
     		    	    	         });
     		    	    	           		    	    	      
            	    	          // Set pub volume field
     		    	    	      rdf.where('<' + doi_url + '> bibo:volume ?volume')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubVolume').val(this.volume.value);
     		    	    	         });
     		    	    	      
            	    	          // Set pub volume field
     		    	    	      rdf.where('<' + doi_url + '> bibo:issue ?issue')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubIssue').val(this.issue.value);
     		    	    	         });
     		    	    	      
            	    	          // Set pub pageStart field
     		    	    	      rdf.where('<' + doi_url + '> bibo:pageStart ?pageStart')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubPageStart').val(this.pageStart.value);
     		    	    	         });

            	    	          // Set pub pageEnd field
     		    	    	      rdf.where('<' + doi_url + '> bibo:pageEnd ?pageEnd')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubPageEnd').val(this.pageEnd.value);
     		    	    	         });
     		    	    	      
            	    	          // Set pub DOI field
     		    	    	      rdf.where('<' + doi_url + '> bibo:doi ?doi')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubDOI').val(this.doi.value);
     		    	    	         });

     		    	    	      // Non-literal assertions, involving several resources that need to be created
     		    	    	      
            	    	          // The pub date: needs an instance of DateTimeValue which holds the date string itself precision indicator (year, month etc.)
     		    	    	      rdf.where('<' + doi_url + '> dc:date ?date')
     		    	    	         .each(function(index) {
     		    	    	        	// figure out year precision from inspecting the string
         		    	    	        $('#pubDateTime').val(this.date.value);
         		    	    	        $('#pubDateTimePrecisionUri').val('http://vivoweb.org/ontology/core#yearMonthDayPrecision')  ;  // (this.date.value);
     		    	    	         });

     		    	    	      // The pub venue: needs an instance of InformationResource
      		    	    	      rdf.where('?pubVenue dc:hasPart <' + doi_url + '>')
      		    	    	         .where('?pubVenue dc:title ?title')
      		    	    	         .where('?pubVenue bibo:issn ?issn')
      		    	    	         .where('?pubVenue a ?type')
  		    	    	             .each(function(index) {
      		    	    	           $('#venueUri').val(this.pubVenue.value);
      		    	    	           $('#venueTitle').val(this.title.value);
      		    	    	           $('#venueISSN').val(this.issn.value);
      		    	    	           $('#venueTypeUri').val(this.type.value);
  		    	    	          });
     		    	    	    		  
     		    	    	      
     		    	    	      // Tease out each of the dc:creator resources too
      		    	    	      rdf.where('<' + doi_url + '> dc:creator ?creator')
  		    	    	             .each(function(index) {
      		    	    	      //  $('#pubDOI').val(this.doi);
  		    	    	          });


     		    	    	      // ? can I pass in a list of creator URIs?
     		    	    	        // each one of those should result in a new 'authorship' assertion

     		    	    	      //rdf.each(function() {
     		    	    	    	//alert('Got this obj: ' + this);  
     		    	    	      //});
     		    	    	      
     		    	    	      
     						       //$('#pubDOI').val(item.doi);
     		    	    	      
     		    	    	      
     			    	    	  // Foreach author, 
     		    	    	      
     		   		    	    	  // ?replace org. title field OR add a new one <input id="titleExternal" />
  				           	    	// unhide CiteULike style form populated w/ metadata, allow user to alter this if he wants?
 	      		    	    	  // $('#externalPubLookupDetails').html('[pub details from RDF to appear here]');
      		    	    	      $('#externalPubLookupDetails').show();
     				    	      
      		    	    	      // For later: add some post-processing here and have UI suggest to user that the pub venue might
      		    	    	      // be already in system. Same for authors. A basic form of supervised disambiguation. 
     		    	    	  });

     	        	       		
     	        	       	} );
   	     	        	  return nRow; // DataTables needs this returned

     	        	       }     	        	       	   
     	        	            
     	        });

	    	    


	    	    	  // TRY LATER: do RDF transformation via the RDF query object and feed to Harvester?

	    	    });     	        

}

// Fill out bibliographic details for publication which user selected from the list of pubs pulled back from the search

function populateExternalBibinfo () {

    alert("clicked on external pub entry w/ input field.value = " + $(this).children("input").val() );
   // get URL to full biblio record - held in a hidden input element inside the div
   // this input.value?
   //start with something simple: just populate pubDOI element + title element and try and get that saved back to the triplestore
    $('#pubDOI').val("[DOI]");
    // children("input").
   // Retrieve full metadata from CrossRef [NB generalize this later for use with PubMed, WorldCat, DataCite and other services]

   //NB skipping over authorlist creation for now - this needs to be handled separately

   // required: title & venue (journal, book publisher etc.)
   // optional: DOI, volume, issue etc. 




// Look into later: use biblio RDF directly and pass to harvester pipeline

}

// error handling here, yes? 


/*
$.ajax({
	url: customForm.acUrl,
    dataType: 'json',
    data: {
    	term: request.term,
        type: customForm.acType
    },
    complete: function(xhr, status) {
    	var results = $.parseJSON(xhr.responseText), 
        filteredResults = customForm.filterAcResults(results);
        customForm.acCache[request.term] = filteredResults;
        response(filteredResults);
    }
});
*/

