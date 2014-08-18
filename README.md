# Growth Replay SDK for iOS

[Growth Replay](https://growthpush.com/) is usability testing tool for mobile apps.

## Usage 

1. Install [Growthbeat Core SDK](https://github.com/SIROK/growthbeat-core-ios).

1. Add GrowthReplay.framework into your project.

1. Import the framework header.

	```objc
	#import <GrowthReplay/GrowthReplay.h>
	```

1. Write initialization code.

	```objc
	[GrowthReplay initializeWithApplicationId:@"APPLICATION_ID" credentialId:@"CREDENTIAL_ID"];
	```

	You can get the APPLICATION_ID and CREDENTIAL_ID on web site of Growth Replay. 

1. Start to capture screen with following code.

	```objc
	[GrowthReplay start];
	```

## Growthbeat Full SDK

You can use Growthbeat SDK instead of this SDK. Growthbeat is growth hack tool for mobile apps. You can use full functions include Growth Replay when you use the following SDK.

* [Growthbeat SDK for iOS](https://github.com/SIROK/growthbeat-ios/)
* [Growthbeat SDK for Android](https://github.com/SIROK/growthbeat-android/)

# Building framework

[iOS-Universal-Framework](https://github.com/kstenerud/iOS-Universal-Framework) is required.

```bash
git clone https://github.com/kstenerud/iOS-Universal-Framework.git
cd ./iOS-Universal-Framework/Real\ Framework/
./install.sh
```

Archive the project on Xcode and you will get framework package.

## License

Apache License, Version 2.0
