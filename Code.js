/**
 *
 * Load Google Sheets data into BigQuery using Apps Script
 *
 */

// global variables
const projectId = 'XXXXXXXXXXXXX'; // project ID listed in the Google Cloud Platform project.
const datasetId = 'XXXXXXXXXXXXX'; // ID of dataset in the BigQuery
const tableId = 'XXXXXXXXXXXXX'; // ID of table in BigQuery

// custom menu
function onOpen() {

  const ui = SpreadsheetApp.getUi();

    ui.createMenu('Upload to BigQuery')
      .addItem('Upload data to BigQuery','loadData')
      .addToUi();
}


// upload Sheets data to BigQuery
function loadData() {
  
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheetId = ss.getId();
  console.log(sheetId);
  const sheet = ss.getSheetByName('Sheet1');
  const lastRow = sheet.getLastRow();
  const lastCol = sheet.getLastColumn();
  //const data = sheet.getDataRange().getValues();
  //console.log(data);
  
  // only run BigQuery load if there is new data
  if (lastRow > 1) {

    // try csv conversion
    try {
      const file = Drive.Files.get(sheetId);
      const url_csv = file.exportLinks['text/csv'];

      const req = UrlFetchApp.fetch(url_csv, {
        method: "GET",
        headers: {
          Authorization: 'Bearer ' + ScriptApp.getOAuthToken()
        }
      });
      var data = req.getBlob().setContentType('application/octet-stream');
    }
    catch(e) {
      // send email with error
      GmailApp.sendEmail('example@example.com','Error: Upload Data To BigQuery, CSV Conversion',e)
    }
    
    // Create the data upload job.
    let job = {
      configuration: {
        load: {
          destinationTable: {
            projectId: projectId,
            datasetId: datasetId,
            tableId: tableId
          },
          sourceFormat: 'CSV',
          skipLeadingRows: 1
        }
      }
    };
    
    // try uploading data into BigQuery
    try {
      // load data into BigQuery
      job = BigQuery.Jobs.insert(job, projectId, data);

      console.log('Load job started. Check on the status of it here: ' +
        'https://bigquery.cloud.google.com/jobs/%s', projectId);

      // send email to confirm job has processed
      GmailApp.sendEmail('example@example.com','Batch Upload Data To BigQuery',(lastRow - 1) + ' rows of data sent to BigQuery')

      // DELETE the data from the Sheet after importing to BigQuery
      sheet.getRange(2,1,lastRow - 1,lastCol).clearContent();

    }
    catch(e) {
      // send email with error
      GmailApp.sendEmail('example@example.com','Error: Upload Data To BigQuery, Upload Error',e)
    }
    
  }
  else {
    console.log('No new data in Sheet');
  }
}

