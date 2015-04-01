import weka.classifiers.functions._
import weka.classifiers.Classifier
import weka.core._
import java.io._
import weka.core.converters.ConverterUtils._
import weka.core.converters.ConverterUtils.DataSource
import weka.classifiers.trees._

object Hi { 
  def main(args:Array[String]) = {
    val source = new DataSource("../../data/raw_arffs/car/car.arff");
    val data = source.getDataSet();
    if (data.classIndex() == -1) {
      data.setClassIndex(data.numAttributes() - 1);
    }

    var clf = new RandomForest()
    clf.buildClassifier(data)

    
  }
}
