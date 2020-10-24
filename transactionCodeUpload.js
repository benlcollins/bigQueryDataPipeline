/**
 * Loads data into BigQuery
 * 
 * Still To Do:
 * what happens if the bigquery upload is happening at the same time zapier is adding new data?
 * 
 * Transactions that are bought using a monthly plan come through with "double" values in some cells
 * Solution 1: stop the upload, send email to me to manually fix
 * Solution 2: TBD when I have a better sense of what they look like, implement a fix in apps script
 * 
 */

// global variables
// UPDATE
const projectId = 'XXXXXXXXXXXXX'; // project ID listed in the Google Cloud Platform project.
const datasetId = 'XXXXXXXXXXXXX'; // ID of dataset in the BigQuery
const tableId = 'XXXXXXXXXXXXX'; // ID of table in BigQuery

// custom menu
function onOpen() {

  const ui = SpreadsheetApp.getUi();

    ui.createMenu('Upload to BigQuery')
      .addItem('Upload data to BigQuery','loadData')
      .addItem('Force Upload','forceUpload')
      .addToUi();
}


// force upload for manually fixed data
function forceUpload() {
  loadData(1);
}


// upload Sheets data to BigQuery
function loadData(overide) {
  
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheetId = ss.getId();
  //console.log(sheetId); 
  const sheet = ss.getSheetByName('Sheet1');
  const lastRow = sheet.getLastRow();
  const lastCol = sheet.getLastColumn();
  const transactions = sheet.getDataRange().getValues();
  console.log(transactions.length);

  // identify if any monthly payment plans in data
  // All Course Bundle Monthly Payment Plan Lifetime Access
  const problemTransactions = transactions.filter( transaction => transaction[8].includes('Monthly Payment Plan'));
  console.log(problemTransactions.length);

  if (problemTransactions.length > 0 && overide !== 1) {
    // data contains monthly payment plans and needs manual clean up
    //console.log('Manual attention required');
    GmailApp.sendEmail('ben@benlcollins.com','Manual Fix Required for Teachable Transactions Data','Transactions contain monthly payment plan and may require fix');
  }
  else {
    //console.log('proceed with BQ upload');
    // transaction data does not contain monthly payment plan data
    // ok to upload to BigQuery
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
        GmailApp.sendEmail('ben@benlcollins.com','Error: Upload Teachable Transactions To BigQuery, CSV Conversion',e)
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
        GmailApp.sendEmail('ben@benlcollins.com','Batch Upload Teachable Transactions To BigQuery',(lastRow - 1) + ' rows of data sent to BigQuery')

        // DELETE the data from the Sheet after importing to BigQuery
        sheet.getRange(2,1,lastRow - 1,lastCol).clearContent();

      }
      catch(e) {
        // send email with error
        GmailApp.sendEmail('ben@benlcollins.com','Error: Upload Teachable Transactions To BigQuery, Upload Error',e)
      }
    }
    else {
      console.log('No new data in Sheet');
    }
  }
}

