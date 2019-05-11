import PxeDetails from '../../../../app/javascript/components/forms/pxe-details'

let renderComponent;
let physicalServers = [1, 2, 3];
let pxeServers = [{value: 'pxe1', label: 'PXE1'}];
let pxeImages = [{value: 'img1', label: 'IMG1'}];
let templates = [{value: 'templ1', label: 'TEMPL1'}];

describe('PxeDetails', () => {
  beforeAll(() => {
    renderComponent = (loading = false, physicalServers = [], pxeServers = [], pxeImages = [], templates = []) => shallowRedux(
      <PxeDetails
        updateFormState={jest.fn()} loading={loading}
        physicalServerIds={physicalServers}
        pxeServers={pxeServers}
        pxeImages={pxeImages}
        customizationTemplates={templates}
      />
      );
  });

  describe('renders', () => {
    it('spinner', () => {
      let component = renderComponent(true);
      expect(toJson(component)).toMatchSnapshot();
    });

    describe('form', () => {
      it('without pxe servers', () => {
        let component = renderComponent(false, physicalServers);
        expect(toJson(component)).toMatchSnapshot();
      });

      it('with pxe servers', () => {
        let component = renderComponent(false, physicalServers, pxeServers);
        expect(toJson(component)).toMatchSnapshot();
      });

      it('with pxe servers and pxe images', () => {
        let component = renderComponent(false, physicalServers, pxeServers, pxeImages);
        expect(toJson(component)).toMatchSnapshot();
      });

      it('with pxe servers and pxe images and templates', () => {
        let component = renderComponent(false, physicalServers, pxeServers, pxeImages, templates);
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });
});
