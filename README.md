
# react-native-calendar-util

## Getting started

`$ npm install kkhung0829/react-native-calendar-util --save`

### Mostly automatic installation

`$ react-native link react-native-calendar-util`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-calendar-util` and add `RNCalendarUtil.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNCalendarUtil.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNCalendarUtilPackage;` to the imports at the top of the file
  - Add `new RNCalendarUtilPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-calendar-util'
  	project(':react-native-calendar-util').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-calendar-util/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-calendar-util')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNCalendarUtil.sln` in `node_modules/react-native-calendar-util/windows/RNCalendarUtil.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Calendar.Util.RNCalendarUtil;` to the usings at the top of the file
  - Add `new RNCalendarUtilPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNCalendarUtil from 'react-native-calendar-util';

// TODO: What to do with the module?
RNCalendarUtil;
```
  