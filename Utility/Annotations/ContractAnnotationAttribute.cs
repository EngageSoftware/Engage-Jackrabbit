﻿// <copyright file="ContractAnnotationAttribute.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;
    using System.Diagnostics.CodeAnalysis;

    /// <summary>Describes dependency between method input and output.</summary>
    /// <syntax>
    ///   <p>Function Definition Table syntax:</p>
    ///   <list>
    ///   <item>FDT      ::= FDTRow [;FDTRow]*</item>
    ///   <item>FDTRow   ::= Input =&gt; Output | Output &lt;= Input</item>
    ///   <item>Input    ::= ParameterName: Value [, Input]*</item>
    ///   <item>Output   ::= [ParameterName: Value]* {halt|stop|void|nothing|Value}</item>
    ///   <item>Value    ::= true | false | null | notnull | canbenull</item>
    ///   </list>
    /// If method has single input parameter, it's name could be omitted. <br />
    /// Using <c>halt</c> (or <c>void</c>/<c>nothing</c>, which is the same) for method output means that the methos doesn't return normally. <br />
    ///   <c>canbenull</c> annotation is only applicable for output parameters. <br />
    /// You can use multiple <c>[ContractAnnotation]</c> for each FDT row, or use single attribute with rows separated by semicolon. <br />
    /// </syntax>
    /// <examples>
    ///   <list>
    ///   <item><code>
    /// [ContractAnnotation("=&gt; halt")]
    /// public void TerminationMethod()
    ///   </code></item>
    ///   <item><code>
    /// [ContractAnnotation("halt &lt;= condition: false")]
    /// public void Assert(bool condition, string text) // Regular Assertion method
    ///   </code></item>
    ///   <item><code>
    /// [ContractAnnotation("s:null =&gt; true")]
    /// public bool IsNullOrEmpty(string s) // String.IsNullOrEmpty
    ///   </code></item>
    ///   <item><code>
    /// A method that returns null if the parameter is null, and not null if the parameter is not null
    /// [ContractAnnotation("null =&gt; null; notnull =&gt; notnull")]
    /// public object Transform(object data)
    ///   </code></item>
    ///   <item><code>
    /// [ContractAnnotation("s:null=&gt;false; =&gt;true,result:notnull; =&gt;false, result:null")]
    /// public bool TryParse(string s, out Person result)
    ///   </code></item>
    ///   </list>
    /// </examples>
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = true, Inherited = true)]
    public sealed class ContractAnnotationAttribute : Attribute
    {
        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "fdt", Justification = "Jetbrains code")]
        public ContractAnnotationAttribute([NotNull] string fdt)
            : this(fdt, false)
        {
        }

        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1704:IdentifiersShouldBeSpelledCorrectly", MessageId = "fdt", Justification = "Jetbrains code")]
        public ContractAnnotationAttribute([NotNull] string fdt, bool forceFullStates)
        {
            this.FDT = fdt;
            this.ForceFullStates = forceFullStates;
        }

        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code"), SuppressMessage("Microsoft.Naming", "CA1709:IdentifiersShouldBeCasedCorrectly", MessageId = "FDT", Justification = "Jetbrains code")]
        public string FDT { get; private set; }

        [SuppressMessage("StyleCop.CSharp.DocumentationRules", "SA1600:ElementsMustBeDocumented", Justification = "Jetbrains code")]
        public bool ForceFullStates { get; private set; }
    }
}