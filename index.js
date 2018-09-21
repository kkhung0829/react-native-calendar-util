'use strict';

import { Platform } from 'react-native';

let RNCalendarUtil;

if (Platform.OS === 'ios') {
    RNCalendarUtil = require('./index.ios').default;
} else {
    RNCalendarUtil = require('./index.android').default;
}

export default RNCalendarUtil;