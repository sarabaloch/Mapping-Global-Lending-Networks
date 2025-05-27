library(httr)
library(jsonlite)
library(tidyverse)
library(plotly)
library(openxlsx)

# setting up the excel workbook and sheet
wb <- createWorkbook()
addWorksheet(wb, "LoanData")

# setting up column headers
writeData(wb, "LoanData", data.frame(year = character(0), creditorCountry = character(0), debtorCountry = character(0), series = character(0), data = numeric(0)), startRow = 1)

# names and id of debtors
url <- "http://api.worldbank.org/v2/country?format=json&per_page=300"
# sending a GET request
response <- GET(url)
countryData <- fromJSON(content(response, as = "text", encoding = "UTF-8"), flatten = TRUE)
str(countryData) #to figure out what it looks like so i can extract the data
# taking 'id' and 'name' columns directly from the data frame
countryList <- data.frame(
  code = countryData[[2]]$id,
  name = countryData[[2]]$name
)
print(countryList) #the entire list

#for credtors
creditor_url <- "http://api.worldbank.org/v2/sources/6/counterpart-area?format=json&per_page=500"
# sending a GET request
creditor_response <- GET(creditor_url)
creditorData <- fromJSON(content(creditor_response, as = "text", encoding = "UTF-8"), flatten = TRUE)
str(creditorData) 
#since it is nested, im doing this
creditorList <- data.frame(
  code = creditorData$source$concept[[1]]$variable[[1]]$id,
  name = creditorData$source$concept[[1]]$variable[[1]]$value
)
print(creditorList) #this includes countries but also other additional creditors too!

rowIndex <- 2  # starting after the header row
series <- "DT.DOD.BLAT.CD"
time <- "all"

#iterating over each creditor and debtor, the rest of the API is referenced from: https://worldbank.github.io/debt-data/creditor-composition/creditor-data-r.html
for (debtor in countryList$code) {
  #the next few lines check if wld (world) path exists for the debtor country, if it doesn't, the country is skipped to speed up the process
  url <- "http://api.worldbank.org/v2/sources/6/country/"
  end <- "?format=json&per_page=500"
  path <- paste(url,debtor,"/series/",series,"/counterpart-area/wld/time/",time,end,sep="")
  print(path)
  
  # Getting the data from the API
  customRequest <- GET(url = path)
  if (http_type(customRequest) == "application/json") {
    for (creditor in creditorList$code) {
      debtor_name <- countryList$name[countryList$code == debtor] #for excel
      creditor_name <- creditorList$name[creditorList$code == creditor]
      
      print(paste("Processing debtor:", debtor, "and creditor:", creditor)) #to track progress since this is v long
      # Setting up the API URL
      url <- "http://api.worldbank.org/v2/sources/6/country/"
      end <- "?format=json&per_page=500"
      path <- paste(url,debtor,"/series/",series,"/counterpart-area/",creditor,"/time/",time,end,sep="")
      
      # Getting the data from the API
      customRequest <- GET(url = path)
      
      # check if the response is JSON (if it exists)
      if (http_type(customRequest) == "application/json") {
        customResponse <- content(customRequest, as = "text", encoding = "UTF-8")
        customJSON <- fromJSON(customResponse, flatten = TRUE)
        
        # Calculate the length of the response data
        listLen <- length(customJSON[["source"]][["data"]][["value"]])
      
        if (listLen > 0) {
          # creating a temporary data frame for this response
          tempData <- data.frame(
            year = sapply(1:listLen, function(i) customJSON[["source"]][["data"]][["variable"]][[i]][[3]][[2]]),
            creditorCountry = creditor_name,
            debtorCountry = debtor_name,
            series = series,
            data = sapply(1:listLen, function(i) as.integer(customJSON[["source"]][["data"]][["value"]][[i]]))
          )
          
          # remove rows with any NA values in tempData
          tempData <- na.omit(tempData)
          
          # write to Excel if there is data left after omitting NA values
          if (nrow(tempData) > 0) {
            # writing data to the excel sheet
            writeData(wb, "LoanData", tempData, startRow = rowIndex, colNames = FALSE)
            print(tempData)
            
            # updating row index
            rowIndex <- rowIndex + nrow(tempData)
          }
        }
      }
    }
  }
}

saveWorkbook(wb, "WorldBankLoanData.xlsx", overwrite = TRUE)
