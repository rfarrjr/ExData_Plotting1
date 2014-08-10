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
DT <- DT[as.Date(Date, format = "%d/%m/%Y") %in% days]

## add some date columns
DT[,datetime := paste(Date, Time, " ")]
DT[,dt2 := as.POSIXct(datetime, format="%d/%m/%Y %H:%M:%S")]
DT[,dow := format(strptime(datetime, format="%d/%m/%Y %H:%M:%S"),format="%a")]

#setup PNG
png("plot4.png", width = 480, height = 480, units = "px")

# set to 2X2 plot panel
par(mfrow=c(2,2))

#x axis for all plots
x <- na.omit(DT[,dt2])

# Plot1 Global Active Power 
y <- as.numeric(na.omit(DT[,Global_active_power]))

plot(x, y, type="l", xlab = "", ylab = "Global Active Power")

# Plot2 Voltage
y <- as.numeric(na.omit(DT[,Voltage]))

plot(x, y, type="l", xlab = "datetime", ylab = "Voltage")

# Plot3 
y1 <- as.numeric(na.omit(DT[,Sub_metering_1]))
y2 <- as.numeric(na.omit(DT[,Sub_metering_2]))
y3 <- as.numeric(na.omit(DT[,Sub_metering_3]))
x <- na.omit(DT[,dt2])

plot(x, y1, type="n", xlab="", ylab="Energy sub metering")

lines(x, y1)
lines(x, y2, col="red")
lines(x, y3, col="blue")

legend("topright", c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
       col = c("black", "red", "blue"), lty=1, bty="n")


# Plot4 Global Reactive power
y <- as.numeric(na.omit(DT[,Global_reactive_power]))

plot(x, y, type="l", xlab = "datetime", ylab = "Global_reactive_power")

dev.off()