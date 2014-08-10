library("data.table")

## download data if not already done
dateDownloaded <- Sys.time()
if (!file.exists("data")) {
  dir.create("data")
  
  temp <- tempfile()
  print(temp)
  url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
  download.file(url, temp, method="curl")
  unzip(temp, exdir = "data")
  unlink(temp)
  
  # capture download time
  fout <- file("data/downloaded.txt")
  writeLines(c(as.character(dateDownloaded)), fout)
  close(fout)
} else {
  fn <- "data/downloaded.txt"
  dateDownloaded <<- as.POSIXct(readChar(fn, file.info(fn)$size))
}

DT <- fread("data/household_power_consumption.txt", sep=';', header=TRUE, na.strings=c('?', "NA"),
            colClasses = c("Date", "character", "numeric", "numeric", "numeric", 
                           "numeric", "numeric", "numeric", "numeric"))

#filter data
days <- c(as.Date("1/2/2007", format = "%d/%m/%Y"),as.Date("2/2/2007", format = "%d/%m/%Y"))

#setup PNG
png("plot1.png", width = 480, height = 480, units = "px")

# Plot data
data <- as.numeric(na.omit(DT[as.Date(Date, format = "%d/%m/%Y") %in% days,Global_active_power]))

hist(data, col="red", main="Global Active Power", xlab="Global Active Power (kilowatts)")

dev.off()