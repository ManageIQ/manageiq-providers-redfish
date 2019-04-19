import React from 'react';
import Enzyme from 'enzyme';
import Adapter from 'enzyme-adapter-react-16';
import configureStore from 'redux-mock-store';
import { shallow, mount } from 'enzyme';
import toJson from 'enzyme-to-json';

// Enzyme configuration and some utility functions.
Enzyme.configure({ adapter: new Adapter() });
global.shallowRedux = (component) => shallow(component, DEFAULT_CONTEXT).dive();
global.mountRedux = (component) => mount(component, DEFAULT_CONTEXT);

// Global variables that Components usually get from elsewhere.
global.ManageIQ = { record: { recordId: -1 } };
global.__ = jest.fn().mockImplementation((val) => `_${val}_`);

// Redux store mocks.
global.mockStore = configureStore();
global.DEFAULT_STORE = mockStore({});
global.DEFAULT_CONTEXT = { context: {store: DEFAULT_STORE} };

// Make common functions available to all tests so we don't need to import every time.
global.shallow = shallow;
global.mount = mount;
global.toJson = toJson;
global.React = React;
