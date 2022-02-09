FROM busybox:latest
CMD ["+%d-%m-%C%y %H:%M:%S"]
ENTRYPOINT ["date"]
