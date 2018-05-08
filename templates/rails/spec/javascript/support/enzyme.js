const Enzyme = require('enzyme');

const EnzymeAdapter = require('enzyme-adapter-react-15.4');

Enzyme.configure({ adapter: new EnzymeAdapter() });

