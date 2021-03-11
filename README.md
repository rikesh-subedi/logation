# logation


## How to use the framework?

1. Import Logation framework in your XCode project
2. Create an object of EQLogger
3. Start logging


## Different ways to log location:

### Fully automatic logger:

```
 let logger = EQLogger(url: "https://enzkng29qixavi0.m.pipedream.net")
 logger.log { payload in
    print(payload)
 }
```

### Manual Logging
```
 let logger = EQLogger(url: "https://enzkng29qixavi0.m.pipedream.net")
 logger.log(lat: 2.3, long: 3.4, accuracy: kCLLocationAccuracyReduced)
```

