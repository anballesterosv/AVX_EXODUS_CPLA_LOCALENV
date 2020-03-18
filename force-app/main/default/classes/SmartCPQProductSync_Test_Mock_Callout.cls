@isTest
global class  SmartCPQProductSync_Test_Mock_Callout implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse(); 
        System.debug('---Endpoint----'+req.getEndpoint());      
            if (req.getEndpoint().endsWith('imports')) {
            System.debug('------1------');
                      //HTTPResponse res = new HTTPResponse();
                      res.setBody('{"id" : "c9ef63cf-627e-4d55-b6cd-bafe9af68b05","type": "IMPORT"}');
                      res.setStatusCode(200);
                      res.setStatus('OK');
                      //return res;
                  }
                  else if(req.getEndpoint().endsWith('file')){
                  System.debug('------2------');
                      //HTTPResponse res = new HTTPResponse();
                      res.setStatus('No Content');
                      res.setStatusCode(204);
                     // return res;    
                  }
                  else if(req.getEndpoint().contains('/imports/')){
                  System.debug('------3------');
                     // HTTPResponse res = new HTTPResponse();
                      res.setStatus('No Content');
                      res.setStatusCode(204);
                     // return res; 
                  }
                  else if(req.getEndpoint().endsWith('eximp/status')){
                  System.debug('------4------');
                     // HTTPResponse res = new HTTPResponse();
                      res.setStatus('OK');
                      res.setStatusCode(200);
                      res.setBody('READY');
                     // return res;
                  }
                  else if(req.getEndpoint().endsWith('eximp/progress')){
                     System.debug('------5------');
                     // HTTPResponse res = new HTTPResponse();
                      res.setStatus('OK');
                      res.setStatusCode(200);
                      //res.setBody{"state":"SUCCEEDED"};
                      String jsonString =  '{"slot":{"id":"f6489918-0997-4d64-8f8b-3ce808ad338c","type":"IMPORT"},"exportType":"FILTER","state":"SUCCEEDED","originalFileName":"product_catalogue_NA_0_20171016111723.xml","startDate":1508177843340,"endDate":1508177855170,"total":{"MP":0,"BVAL":1,"BMAC":0,"LA":0,"SPGP":0,"CCG":0,"IG":0,"BVAR":0,"CPG":0,"FORM":0,"PPM":0,"SE":0,"CP":0,"BPS":0,"STPG":0,"SSI":1,"TPL":0,"CFG":0,"GRP":0,"WC":0,"BRC":0,"SPGL":0,"TEA":0,"SCT":0,"DW":0,"OPN":0,"CB":0,"SCG":0,"CSM":0,"OPR":0,"CL":9,"PARAM":0,"SP":0,"MC":0,"TVC":0,"RTG":0,"RMO":0,"DCG":0,"BDT":0,"SFG":0,"SG":0,"TC":0},"current":{"MP":0,"BVAL":1,"BMAC":0,"LA":0,"SPGP":0,"CCG":0,"IG":0,"BVAR":0,"CPG":0,"FORM":0,"PPM":0,"SE":0,"CP":0,"BPS":0,"STPG":0,"SSI":1,"TPL":0,"CFG":0,"GRP":0,"WC":0,"BRC":0,"SPGL":0,"TEA":0,"SCT":0,"DW":0,"OPN":0,"CB":0,"SCG":0,"CSM":0,"OPR":0,"CL":9,"PARAM":0,"SP":0,"MC":0,"TVC":0,"RTG":0,"RMO":0,"DCG":0,"BDT":0,"SFG":0,"SG":0,"TC":0},"exception":"","version":{"name":null,"working":true},"fixNumber":0}';
                      //String accountsJSON = JSON.serialize(jsonString);
                      //res.setBody(JSON.serialize(jsonString));
                      res.setBody(jsonString);
                     // return res;    
                  }
                  else if(req.getEndpoint().contains('/versioning/Version')){
                  System.debug('------6------');
                     // HTTPResponse res = new HTTPResponse();
                      res.setStatus('No Content');
                      res.setStatusCode(204);
                     // return res;    
                  }
                  else if(req.getEndpoint().contains('/versioning/progress')){
                  System.debug('------7------');
                     // HTTPResponse res = new HTTPResponse();
                      res.setStatus('OK');
                      res.setStatusCode(200);
                      String jsonString = '{"state":"SUCCEEDED","versionOperationInfo":{"label":"Version 1508265170997","operationType":"FULL_VERSION","fixNumber":0},"exception":""}';
                      res.setBody(JSON.serialize(jsonString));
                      //res.setState('SUCCEEDED');
                      //return res;    
                  }
                  else if(req.getEndpoint().contains('/serialization/versions/Version')){
                  System.debug('------8------');
                     // HTTPResponse res = new HTTPResponse();
                      res.setStatus('No Content');
                      res.setStatusCode(204);
                      //res.setState('SUCCEEDED');
                     // return res;    
                  }
                  else if(req.getEndpoint().endsWith('/deleteVersionWorkflow?nbVersion=5')){
                  System.debug('------9------');
                     // HTTPResponse res = new HTTPResponse();
                      res.setStatus('No Content');
                      res.setStatusCode(204);
                     // return res;    
                  }
                  else if(req.getEndpoint().endsWith('/deleteVersionWorkflow/progress')){
                  System.debug('------10------');
                      //HTTPResponse res = new HTTPResponse();
                      res.setStatus('OK');
                      res.setStatusCode(200);
                      //res.setState('SUCCEEDED');
                     // return res;    
                  }else{
                      // Optionally, only send a mock response for a specific endpoint
                      // and method.
                      //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
                      //System.assertEquals('GET', req.getMethod());
                      
                      // Create a fake response
                      res.setHeader('Content-Type', 'application/json');
                      res.setBody('{"foo":"bar"}');
                      res.setStatusCode(200);
                  }
					return res;
        }
}