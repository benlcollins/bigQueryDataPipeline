/**
 * save new row of alexa data
 */
function saveAlexaData() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const dataSheet = ss.getSheetByName("alexa_rankings");
  const settingsSheet = ss.getSheetByName("settings");
  
  // get the url, follower count and date from the first three cells
  const timestamp = settingsSheet.getRange(14,2).getValue();
  const global_count = settingsSheet.getRange(11,2).getValue();
  const us_count = settingsSheet.getRange(11,3).getValue();
  
  // paste them into the bottom row of your spreadsheet
  dataSheet.appendRow([
    timestamp,
    global_count,
    us_count]);
};
