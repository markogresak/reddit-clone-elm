const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const nodeEnv = process.env.NODE_ENV || 'development';
const isProduction = nodeEnv === 'production';

const sourcePath = path.join(__dirname, './src');
const buildPath = path.join(__dirname, './build');

let plugins = [
  new HtmlWebpackPlugin({
    template: path.join(sourcePath, 'index.html'),
    path: buildPath,
    filename: 'index.html',
    favicon: path.join(sourcePath, './assets/favicon.ico'),
  }),
];

if (isProduction) {
  plugins = [
    ...plugins,
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false,
    }),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false,
        screw_ie8: true,
        conditionals: true,
        unused: true,
        comparisons: true,
        sequences: true,
        dead_code: true,
        evaluate: true,
        if_return: true,
        join_vars: true,
      },
      output: {
        comments: false,
      },
    }),
  ];
}

module.exports = {
  entry: {
    app: [
      'normalize.css',
      path.join(sourcePath, './index.js')
    ],
  },

  output: {
    path: buildPath,
    publicPath: '/',
    filename: 'app-[hash].js',
  },

  module: {
    noParse: /\.elm$/,
    rules: [
      {
        test: /\.(css|scss)$/,
        use: ['style-loader', 'css-loader']
      },
      {
        test: /\.elm$/,
        exclude: [
          /elm-stuff/, /node_modules/
        ],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            debug: !isProduction,
            verbose: !isProduction,
            warn: !isProduction,
          },
        },
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff'
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader'
      },
    ],
  },

  plugins,

  devServer: {
    inline: true,
    historyApiFallback: true,
    stats: {
      timings: true,
      colors: true,
    },
  },
};
