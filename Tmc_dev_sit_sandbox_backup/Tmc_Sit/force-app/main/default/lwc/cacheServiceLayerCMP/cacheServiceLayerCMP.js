// eslint-disable-next-line no-console
import DailingListCacheKey from "@salesforce/label/c.Dailing_List_Cache_Key";

//Saves a String to localStorage. After saving returns true.
export function saveStringToCache(cacheString) {
  localStorage.setItem(DailingListCacheKey, cacheString);
  return true;
}

//Takes a String Array as input parameter and Save as Object Array to localStorage. After saving returns true.
export function saveStringArrayAsObjectArray(dailingListStringArray) {
  
  var getData = dailingListStringArray;

  var dailinglist = JSON.parse(JSON.stringify(getData));
  var customerDetailsOnjectArray = {
    campaignName: dailinglist[0],
    campaignType: dailinglist[1],
    RegNum: dailinglist[2],
    ServiceDueDate: dailinglist[3],
    customerTaskId: dailinglist[4]
  };
  localStorage.setItem(
    DailingListCacheKey,
    JSON.stringify(customerDetailsOnjectArray)
  );
  return true;
}

//Takes a JSON or JSON object as input parameter and Saves to localStorage. After saving returns true.
export function saveJSONtoCache(JSONObject) {
  localStorage.setItem(DailingListCacheKey, JSONObject);
  return true;
}

//Fetches the String stored in localStorage and returns String
export function retrieveStringFromCache() {
  return localStorage.getItem(DailingListCacheKey);
}

//Fetches the Object Array stored in localStorage and returns Object Array. Data can be access using "objectName.FIeldName"
export function retrieveObjectArrayFromCache() {
  return JSON.parse(localStorage.getItem(DailingListCacheKey));
}

//Clears LocalStorage Data with Key DailingListData 
export function clearLocalStorageWithKey() {
  return localStorage.removeItem(DailingListCacheKey);
}

//Clears all of the LocalStorage irrespective of the keys
export function clearAllLocalStorage() {
  return localStorage.clear();
}