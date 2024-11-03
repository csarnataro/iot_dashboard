// WidgetGridHook.js

import { GridStack } from 'gridstack';


function positions(items) {
  return items.reduce((acc, item) => {
    let widgetId = item.el.id;
    acc[widgetId] = {
      x: item.x,
      y: item.y,
      width: item.w,
      height: item.h,
    };
    return acc;
  }, {});
}

// gridstack options here
const options = {
//   cellHeight: 40, // use 'auto' to make square
//   animate: true, // show immediate (animate: true is nice for user dragging though)
//   columnOpts: {
//     columnWidth: 100, // wanted width
//   },
//   children: items,
  float: false,
  column: 24,
  cellHeight: 'initial',
  handle: '.card-header'
};

const GridStackHook = {
  mounted() {
    this.grid = GridStack.init(options);

    this.grid.on("change", (_event, items) => {
      if (items) {
        this.pushEvent("widget:move", { positions: positions(items) });
      }
    });
  },

  beforeUpdate() {
    this.grid.destroy(false);
  },

  updated() {

    this.grid = GridStack.init(options);

    this.grid.on("change", (_event, items) => {
      if (items) {
        this.pushEvent("widget:move", { positions: positions(items) });
      }
    });
  },

  beforeDestroy() {
    this.grid.destroy(false);
  },
};

export { GridStackHook };
