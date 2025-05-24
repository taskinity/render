const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'taskinity-render.min.js',
    path: path.resolve(__dirname, 'dist'),
    library: {
      name: 'TaskinityRender',
      type: 'umd',
      export: 'default',
      umdNamedDefine: true
    },
    globalObject: 'this'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      }
    ]
  }
};
