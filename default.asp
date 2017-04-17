<!doctype html>
<html lang="en">
  <head>
    <script src="js/jquery-2.0.3.min.js" type="text/javascript"></script>
    <script src="js/bootstrap.min.js" type="text/javascript"></script>
    <script src="js/pdf.js" type="text/javascript"></script>
    <script src="js/ui_utils.js" type="text/javascript"></script>
    <link href="css/bootstrap.min.css" rel="stylesheet">
  <script>
  
    PDFJS.workerSrc = 'js/pdf.worker.js';

    $(function () {

      convertToBase64();
	  
    });
    function convertToBase64() {
        //Read File
        

        $('#pdfContainer').empty();
		
		pathArray = location.href.split( '/' );
		var basePath = pathArray[0] + '//' + pathArray[2];
			
//          PDFJS.getDocument('<% if Request.QueryString("pdfname") = "" then Response.Write("QM-Handbuch.pdf") else Response.Write(Request.QueryString("pdfname")) %>').then(function (pdf) {
			PDFJS.getDocument('<% if Request.QueryString("pdfname") = "" then Response.Write("QM-Handbuch.pdf") else Response.Write(Request.QueryString("pdfname")) %>').then(function (pdf) {

            var numPages = pdf.pdfInfo.numPages;

            for(var i=0; i<numPages; i++) {


              pdf.getPage(i+1).then(function(page) {
                var scale = 1.5;
                var viewport = page.getViewport(scale);

                var canvas = document.createElement('canvas');
                canvas.id = 'the-canvas'+i;



                var context = canvas.getContext('2d');
                canvas.height = viewport.height;
                canvas.width = viewport.width;

                var renderContext = {
                  canvasContext: context,
                  viewport: viewport
                };
                page.render(renderContext);



                var annotationLayer = document.createElement('div');
                $(annotationLayer).addClass('annotationLayer');

                var pageDiv = document.createElement('div');


                $(pageDiv).append(canvas);
                $(pageDiv).append(annotationLayer);

                $('#pdfContainer').append(pageDiv);
				
				
				
				var basePath = '<% if Request.QueryString("pdfname") = "" then Response.Write("QM-Handbuch.pdf") else Response.Write(Request.QueryString("pdfname")) %>';
                setupAnnotations(page, viewport, canvas, annotationLayer, basePath);



              });


            }


            
          
        });



		function changeRelToAbsUrl(base, relative) {
			var stack = base.split("/"),
				parts = relative.split("/"),
				stack2 = [],
				partslen = parts.length;
			
			stack.pop(); // remove current file name (or empty string)
						 // (omit if "base" is the current folder without trailing slash)
						 
			if(partslen == 1) {
				stack.push(relative);
				return stack.join("/");
			}
			
			for (var i=0; i<parts.length; i++) {
				if (parts[i] == ".")
					continue;
				if (parts[i] == "..")
					stack.pop();
				else {
					stack.push(parts[i]);
					stack2.push(parts[i]);
				}
			}
			if(stack2.length == partslen)
				return stack2.join('/');
			else
				return stack.join("/");
		}



        function setupAnnotations(page, viewport, canvas, $annotationLayerDiv, basePath) {
          var canvasOffset = $(canvas).offset();
          var promise = page.getAnnotations().then(function (annotationsData) {
            viewport = viewport.clone({
              dontFlip: true
            });

            for (var i = 0; i < annotationsData.length; i++) {
              var data = annotationsData[i];
              



              var element = document.createElement('a');

			  var realpath = changeRelToAbsUrl(basePath, data.unsafeUrl);
              element.href = "default.asp?pdfname="+realpath;
              
              element.style.height = '12px';
              element.target = '_blank';


              var rect = data.rect;
              var view = page.view;

              element.style.width = (rect[2]-rect[0])+'px';


              rect = PDFJS.Util.normalizeRect([
                rect[0],
                view[3] - rect[1] + view[1],
                rect[2],
                view[3] - rect[3] + view[1]]);
              element.style.left = (canvasOffset.left + rect[0]) + 'px';
              element.style.top = (canvasOffset.top + rect[1]) + 'px';
              element.style.position = 'absolute';

              var transform = viewport.transform;
              var transformStr = 'matrix(' + transform.join(',') + ')';
              CustomStyle.setProp('transform', element, transformStr);
              var transformOriginStr = -rect[0] + 'px ' + -rect[1] + 'px';
              CustomStyle.setProp('transformOrigin', element, transformOriginStr);



              $($annotationLayerDiv).append(element);




            }

            
          });
          return promise;
        }
    }
    function loadPDFData(base64pdfData) {
      /*jshint multistr: true */
  //    var base64pdfData = ''; //should contain base64 representing the PDF

      function base64ToUint8Array(base64) {
        var raw = atob(base64);
        var uint8Array = new Uint8Array(new ArrayBuffer(raw.length));
        for (var i = 0, len = raw.length; i < len; ++i) {
          uint8Array[i] = raw.charCodeAt(i);
        }
        return uint8Array;
      }
      return base64ToUint8Array(base64pdfData);
    }

    </script>
    <style>
      body {
          font-family: arial, verdana, sans-serif;
      }
      .pdf-content {
          border: 1px solid #000000;
      }
      .annotationLayer > a {
          display: block;
          position: absolute;
      }
      .annotationLayer > a:hover {
          opacity: 0.2;
          background: #ca0;
          box-shadow: 0px 2px 10px #ff0;
      }
      .annotText > div {
          z-index: 200;
          position: absolute;
          padding: 0.6em;
          max-width: 20em;
          background-color: #FFFF99;
          box-shadow: 0px 2px 10px #333;
          border-radius: 7px;
      }
      .annotText > img {
          position: absolute;
          opacity: 0.6;
      }
      .annotText > img:hover {
          opacity: 1;
      }
      .annotText > div > h1 {
          font-size: 1.2em;
          border-bottom: 1px solid #000000;
          margin: 0px;
      }

    </style>
    
  </head>
  <body>
    <div class="container-fluid">
      
      <div class="row">
        <div class="col-sm-6">
          <div id="pdfContainer">
            
          </div>
        </div>
      </div>
    </div>
  </body>
  
</html>
